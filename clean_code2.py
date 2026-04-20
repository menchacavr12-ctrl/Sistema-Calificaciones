import os
import re

def aggressive_clean(filepath):
    ext = os.path.splitext(filepath)[1]
    
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    new_lines = []
    
    for line in lines:
        stripped = line.strip()
        
        # Omitir separadores raros que quedaron
        if stripped.startswith('# ──') or stripped.startswith('// ──') or stripped.startswith('/* ──'):
            continue
            
        if ext == '.py':
            # Quitar todas las lineas de puro comentario excepto las muy importantes
            if stripped.startswith('#'):
                # Evitar borrar cosas como '# -*- coding... o TODOs, aunque aqui podemos limpiar todo
                if not any(k in stripped.lower() for k in ['evitar mandar', 'conectar', 'rutas principal', 'manejar sockets']):
                    continue # Lo borramos!
        elif ext == '.dart':
            if stripped.startswith('//'):
                if not any(k in stripped.lower() for k in ['manejar estado', 'iniciar app', 'conexion al server', 'endpoint']):
                    continue # Lo borramos!
        
        # Eliminar summary="algo" en los routers
        if 'summary="' in line:
            line = re.sub(r',\s*summary="[^"]+"', '', line)
            line = re.sub(r'summary="[^"]+",\s*', '', line)

        new_lines.append(line)
        
    content = "".join(new_lines)
    # Limpiar saltos dobles innecesarios
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
                aggressive_clean(filepath)

if __name__ == "__main__":
    print("Iniciando limpieza agresiva de comentarios...")
    walk_dir('backend/app')
    walk_dir('backend/scripts')
    walk_dir('frontend/lib')
    print("Limpieza completada.")
