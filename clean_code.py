import os
import re

def clean_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove Emojis (a basic regex block for common emojis)
    emojis = [
        "✅", "🔌", "🚀", "📌", "❌", "👨‍🏫", "📅", "🍃", "📦", "🎉", "✨", 
        "📱", "💻", "🟢", "🔴", "💡", "⚠️", "🎓", "😎", "🛠️", "💬", "🤖", "🔥", "⚙️", "👤", "🗄️", "🗝️", "🛡️", "🔑", "💳"
    ]
    for e in emojis:
        content = content.replace(e, "")

    # Clean up decorators like # ─── Header ─────
    content = re.sub(r'#\s*─+.*?(─+)?\n', '\n', content)
    content = re.sub(r'//\s*─+.*?(─+)?\n', '\n', content)

    # Some typical AI comments
    content = content.replace("# Limpiar datos sensibles", "# evitar mandar contraseñas")
    content = content.replace("// URL base del backend - se auto-detecta según la plataforma", "// conexion al server")
    content = content.replace("# ── Gestor de conexiones WebSocket", "# manejar sockets")
    content = content.replace("##", "#")

    # Remove trailing spaces
    lines = [line.rstrip() for line in content.split('\n')]
    content = '\n'.join(lines)

    # Remove multiple blank lines
    content = re.sub(r'\n{3,}', '\n\n', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

def walk_dir(directory):
    for root, dirs, files in os.walk(directory):
        if "venv" in root or ".git" in root or "__pycache__" in root or "build" in root or ".dart_tool" in root:
            continue
        for file in files:
            if file.endswith('.py') or file.endswith('.dart'):
                filepath = os.path.join(root, file)
                clean_file(filepath)

if __name__ == "__main__":
    print("Iniciando limpieza...")
    walk_dir('backend/app')
    walk_dir('backend/scripts')
    walk_dir('frontend/lib')
    print("Limpieza completada.")
