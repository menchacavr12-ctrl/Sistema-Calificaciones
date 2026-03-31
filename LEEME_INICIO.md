# 🚀 Sistema de Calificaciones - Guía de Inicio

¡Hola! Veo que apagaste la computadora. No te preocupes, es normal que los servidores se detengan al apagar la PC. Aquí tienes una explicación sencilla de qué pasó y cómo encenderlo todo de nuevo fácilmente.

## ❓ ¿Qué pasó?
El sistema tiene dos partes principales (como un restaurante):
1. **El Backend (La Cocina)**: Es donde vive la base de datos (MongoDB) y toda la lógica. Se corre con Python y FastAPI.
2. **El Frontend (El Mesero)**: Es la aplicación de Flutter que ves en tu navegador.

Al apagar la PC, "la cocina" se cerró. Por eso tu aplicación decía **"Error de conexión con el servidor"**.

---

## ⚡ Cómo encenderlo todo de nuevo (Método rápido)

He preparado dos formas para que lo hagas:

### Opción A: Usar el script de inicio automático (RECOMENDADO)
He creado un archivo llamado `encender_sistema.bat` en la carpeta principal del proyecto.
1. Abre la carpeta `d:\Proyectos\Calificaciones`.
2. Haz doble clic en `encender_sistema.bat`.
3. ¡Listo! Se abrirán las terminales necesarias automáticamente.

### Opción B: Manual (Paso a paso)
Si prefieres hacerlo a mano, sigue estos pasos:

#### 1. Encender la "Cocina" (Backend)
1. Abre una terminal en `d:\Proyectos\Calificaciones\backend`.
2. Escribe estos comandos:
   ```powershell
   .\venv\Scripts\activate
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
3. Debes ver un mensaje que dice: `✅ Conectado a MongoDB`.

#### 2. Encender la Aplicación (Frontend)
1. Abre otra terminal en `d:\Proyectos\Calificaciones\frontend`.
2. Escribe:
   ```powershell
   flutter run -d chrome
   ```
3. Tu navegador se abrirá con el sistema listo para usar.

---

## 🛠️ Notas importantes
- **MongoDB**: Asegúrate de que MongoDB Atlas (tu base de datos en la nube) esté activa. Normalmente siempre lo está a menos que cambies tu contraseña o IP en el portal de Atlas.
- **Refrescar**: Si ya tienes la ventana de Chrome abierta con el error, una vez que enciendas el backend (Paso 1), simplemente presiona **F5** o el botón de recargar en tu navegador.

¡Ya encendí todo por ti! Puedes refrescar tu página ahora.
