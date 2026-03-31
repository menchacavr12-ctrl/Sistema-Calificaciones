import asyncio
import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
from app.utils.jwt_handler import hash_password
from datetime import datetime

# Cargar configuración
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "calificaciones_db")

async def seed():
    print(f"🚀 Iniciando semillado completo en {MONGO_DB_NAME}...")
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[MONGO_DB_NAME]

    # 1. Limpiar colecciones
    collections = ["users", "clases", "alumno_clases", "horarios", "opiniones", "ayuda", "notificaciones"]
    for coll in collections:
        await db[coll].drop()
        print(f"🧹 Colección '{coll}' eliminada.")

    password_shared = hash_password("123456")
    violet_color = "#7C3AED"

    # 2. Insertar Usuarios
    users_data = [
        {
            "username": "emiliano",
            "email": "emiliano@example.com",
            "full_name": "Emiliano (Admin)",
            "hashed_password": password_shared,
            "role": "super_admin",
            "status": "activo",
            "is_verified": True,
            "created_at": datetime.utcnow()
        },
        {
            "username": "glenda",
            "email": "glenda@maestra.com",
            "full_name": "Profa. Glenda",
            "hashed_password": password_shared,
            "role": "maestro",
            "especialidad": "Pedagogía y Tics",
            "status": "activo",
            "is_verified": True,
            "created_at": datetime.utcnow()
        },
        {
            "username": "smith",
            "email": "smith@maestro.com",
            "full_name": "Prof. Smith",
            "hashed_password": password_shared,
            "role": "maestro",
            "especialidad": "Ingeniería de Software",
            "status": "activo",
            "is_verified": True,
            "created_at": datetime.utcnow()
        },
        {
            "username": "lopez",
            "email": "lopez@maestro.com",
            "full_name": "Prof. Lopez",
            "hashed_password": password_shared,
            "role": "maestro",
            "especialidad": "Matemáticas",
            "status": "activo",
            "is_verified": True,
            "created_at": datetime.utcnow()
        },
        {
            "username": "juanito",
            "email": "juanito@alumno.com",
            "full_name": "Juan Perez",
            "hashed_password": password_shared,
            "role": "alumno",
            "numero_control": "210345",
            "semestre": 6,
            "grupo": "6°C",
            "status": "activo",
            "is_verified": True,
            "created_at": datetime.utcnow()
        },
        {
            "username": "maria",
            "email": "maria@alumno.com",
            "full_name": "Maria Garcia",
            "hashed_password": password_shared,
            "role": "alumno",
            "numero_control": "210678",
            "semestre": 6,
            "grupo": "6°C",
            "status": "activo",
            "is_verified": True,
            "created_at": datetime.utcnow()
        }
    ]
    
    user_results = await db["users"].insert_many(users_data)
    user_ids = [str(uid) for uid in user_results.inserted_ids]
    
    emiliano_id, glenda_id, smith_id, lopez_id, juanito_id, maria_id = user_ids
    print(f"✅ {len(user_ids)} usuarios creados.")

    # 3. Insertar Clases (Materias)
    clases_data = [
        {
            "nombre": "Pedagogia y Tics",
            "grupo": "6°C",
            "semestre": 6,
            "color": violet_color,
            "maestro_id": glenda_id,
            "codigo_acceso": "PED6C",
            "alumnos": [juanito_id, maria_id],
            "is_active": True,
            "created_at": datetime.utcnow()
        },
        {
            "nombre": "Integracion de Software",
            "grupo": "6°C",
            "semestre": 6,
            "color": violet_color,
            "maestro_id": smith_id,
            "codigo_acceso": "INT6C",
            "alumnos": [juanito_id],
            "is_active": True,
            "created_at": datetime.utcnow()
        },
        {
            "nombre": "Matematicas",
            "grupo": "6°C",
            "semestre": 6,
            "color": violet_color,
            "maestro_id": lopez_id,
            "codigo_acceso": "MAT6C",
            "alumnos": [juanito_id, maria_id],
            "is_active": True,
            "created_at": datetime.utcnow()
        }
    ]

    clase_results = await db["clases"].insert_many(clases_data)
    clase_ids = [str(cid) for cid in clase_results.inserted_ids]
    ped_clase, int_clase, mat_clase = clase_ids
    print(f"✅ {len(clase_ids)} clases creadas.")

    # 4. Insertar Horarios (Bloques Individuales)
    # Formato: dia, hora, materia, maestro, aula, color, usuario_id
    horarios_data = []

    # Bloque 1: Integración de Software (Lunes 07:00 - 07:50)
    for uid in [juanito_id, smith_id]:
        horarios_data.append({
            "dia": "Lunes", "hora": "07:00 - 07:50", "materia": "Integración de Software",
            "maestro": "Smith", "aula": "#4", "color": violet_color, "usuario_id": uid
        })

    # Bloque 2: Matemáticas (Lunes 07:50 - 08:40)
    for uid in [juanito_id, maria_id, lopez_id]:
        horarios_data.append({
            "dia": "Lunes", "hora": "07:50 - 08:40", "materia": "Matemáticas",
            "maestro": "Lopez", "aula": "#4", "color": violet_color, "usuario_id": uid
        })

    # Bloque 3: Pedagogía (Lunes 08:40 - 09:30)
    for uid in [juanito_id, maria_id, glenda_id]:
        horarios_data.append({
            "dia": "Lunes", "hora": "08:40 - 09:30", "materia": "Pedagogía y Tics",
            "maestro": "Glenda", "aula": "#4", "color": violet_color, "usuario_id": uid
        })

    await db["horarios"].insert_many(horarios_data)
    print(f"✅ {len(horarios_data)} bloques de horario creados.")

    # 5. Insertar Calificaciones (alumno_clases)
    alumno_clases_data = [
        # Juanito en Pedagogía
        {
            "alumno_id": juanito_id, "clase_id": ped_clase, "promedio": 90.0,
            "calificaciones": [
                {"parcial": 1, "valor": 90.0, "fecha_asignacion": datetime.utcnow()},
                {"parcial": 2, "valor": 100.0, "fecha_asignacion": datetime.utcnow()}
            ],
            "created_at": datetime.utcnow()
        },
        # Juanito en Integración
        {
            "alumno_id": juanito_id, "clase_id": int_clase, "promedio": 85.0,
            "calificaciones": [
                {"parcial": 1, "valor": 85.0, "fecha_asignacion": datetime.utcnow()}
            ],
            "created_at": datetime.utcnow()
        },
        # Maria en Matemáticas
        {
            "alumno_id": maria_id, "clase_id": mat_clase, "promedio": 75.0,
            "calificaciones": [
                {"parcial": 1, "valor": 75.0, "fecha_asignacion": datetime.utcnow()}
            ],
            "created_at": datetime.utcnow()
        }
    ]
    await db["alumno_clases"].insert_many(alumno_clases_data)
    print(f"✅ {len(alumno_clases_data)} registros de calificaciones creados.")

    # 6. Insertar Opiniones (Reseñas)
    opiniones_data = [
        # Opiniones para Glenda
        {"alumno_id": maria_id, "maestro_id": glenda_id, "calificacion": 5, "comentario": "Excelente maestra, muy paciente.", "created_at": datetime.utcnow()},
        {"alumno_id": juanito_id, "maestro_id": glenda_id, "calificacion": 4, "comentario": "Muy buena clase.", "created_at": datetime.utcnow()},
        # Opiniones para Smith
        {"alumno_id": juanito_id, "maestro_id": smith_id, "calificacion": 5, "comentario": "Explica muy bien los conceptos técnicos.", "created_at": datetime.utcnow()},
        # Opiniones para Lopez
        {"alumno_id": maria_id, "maestro_id": lopez_id, "calificacion": 3, "comentario": "La clase es un poco pesada pero se aprende.", "created_at": datetime.utcnow()}
    ]
    await db["opiniones"].insert_many(opiniones_data)
    print(f"✅ {len(opiniones_data)} reseñas creadas.")

    print("\n✨ Semillado FINAL completado con éxito.")
    print("-" * 30)
    print("RESUMEN GENERAL:")
    print(f"• Usuarios: {len(users_data)}")
    print(f"• Clases: {len(clases_data)}")
    print(f"• Password común: 123456")
    print("-" * 30)

    client.close()

if __name__ == "__main__":
    asyncio.run(seed())
