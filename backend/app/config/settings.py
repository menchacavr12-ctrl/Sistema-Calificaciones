import os
from dotenv import load_dotenv

load_dotenv()

# App
APP_NAME = os.getenv("APP_NAME", "Sistema de Calificaciones EmilianitoProGamer")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
DEBUG = os.getenv("DEBUG", "True") == "True"

# JWT
SECRET_KEY = os.getenv("SECRET_KEY", "CAMBIA_ESTA_CLAVE_EN_PRODUCCION")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))

# Email
MAIL_USERNAME = os.getenv("MAIL_USERNAME", "")
MAIL_PASSWORD = os.getenv("MAIL_PASSWORD", "")
MAIL_FROM = os.getenv("MAIL_FROM", "")
MAIL_PORT = int(os.getenv("MAIL_PORT", "587"))
MAIL_SERVER = os.getenv("MAIL_SERVER", "smtp.gmail.com")

# Google OAuth
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "")
GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET", "")

# Código de verificación
VERIFICATION_CODE_EXPIRE_MINUTES = 3
