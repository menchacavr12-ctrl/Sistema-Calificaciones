import smtplib
import random
import string
import asyncio
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.config.settings import MAIL_USERNAME, MAIL_PASSWORD, MAIL_FROM, MAIL_PORT, MAIL_SERVER, APP_NAME

def generate_verification_code(length: int = 5) -> str:
    """Genera un código numérico de N dígitos"""
    return ''.join(random.choices(string.digits, k=length))

def _send_email_sync(to_email: str, code: str, username: str) -> bool:
    """Envío síncrono del email (se ejecuta en un thread separado)"""
    try:
        if not MAIL_USERNAME or not MAIL_PASSWORD or MAIL_USERNAME == "tucorreo@gmail.com":
            print(f" Email no configurado. Código para {to_email}: {code}")
            return False

        msg = MIMEMultipart("alternative")
        msg["Subject"] = f" Código de Verificación - {APP_NAME}"
        msg["From"] = MAIL_FROM
        msg["To"] = to_email

        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body {{ font-family: Arial, sans-serif; background-color: #f0f0f0; margin: 0; padding: 20px; }}
                .container {{ max-width: 480px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }}
                .header {{ background: linear-gradient(135deg, #1a237e, #4a148c); padding: 30px; text-align: center; }}
                .header h1 {{ color: white; margin: 10px 0 0; font-size: 18px; }}
                .body {{ padding: 30px; text-align: center; }}
                .greeting {{ color: #333; font-size: 16px; margin-bottom: 10px; }}
                .message {{ color: #666; font-size: 14px; margin-bottom: 25px; }}
                .digit {{ width: 45px; height: 55px; background: #f5f5f5; border: 2px solid #7C3AED; border-radius: 10px; display: inline-flex; align-items: center; justify-content: center; font-size: 28px; font-weight: bold; color: #4a148c; margin: 0 5px; }}
                .timer {{ background: #22c55e; color: white; border-radius: 20px; padding: 8px 20px; font-size: 13px; display: inline-block; margin-top: 15px; }}
                .footer {{ background: #f9f9f9; padding: 20px; text-align: center; font-size: 12px; color: #999; }}
                .warning {{ color: #ef4444; font-size: 13px; margin-top: 15px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1> {APP_NAME}</h1>
                </div>
                <div class="body">
                    <p class="greeting">¡Hola, <strong>{username}</strong>!</p>
                    <p class="message">Te acabamos de enviar un código de verificación.<br>Verifica cuál es y pégalo en la app:</p>
                    <div style="text-align: center;">
                        {''.join([f'<span class="digit">{d}</span>' for d in code])}
                    </div>
                    <div class="timer">⏱ Tiempo de expiración: 3:00 minutos</div>
                    <p class="warning"> Si no solicitaste este código, ignora este correo.</p>
                </div>
                <div class="footer">
                    <p>© 2025 {APP_NAME}. Todos los derechos reservados.</p>
                </div>
            </div>
        </body>
        </html>
        """

        msg.attach(MIMEText(html, "html"))

        with smtplib.SMTP(MAIL_SERVER, MAIL_PORT, timeout=10) as server:
            server.ehlo()
            server.starttls()
            server.login(MAIL_USERNAME, MAIL_PASSWORD)
            server.sendmail(MAIL_FROM, to_email, msg.as_string())

        print(f" Email enviado a {to_email}")
        return True
    except Exception as e:
        print(f" Error enviando email a {to_email}: {e}")
        print(f" Código de verificación para {to_email}: {code}")
        return False

async def send_verification_email(to_email: str, code: str, username: str) -> bool:
    """
    Envía el email de verificación de forma asíncrona (no bloquea el server).
    Si el SMTP no está configurado, solo imprime el código en consola.
    """
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, _send_email_sync, to_email, code, username)
