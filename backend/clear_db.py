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

async def clear():
    print(f"🧹 Limpiando base de datos {MONGO_DB_NAME}...")
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[MONGO_DB_NAME]

    # 1. Eliminar colecciones de datos
    collections = ["clases", "alumno_clases", "horarios", "opiniones", "ayuda", "notificaciones"]
    for coll in collections:
        await db[coll].drop()
        print(f"🗑️ Colección '{coll}' eliminada.")

    # 2. Limpiar usuarios y recrear admin
    await db["users"].drop()
    print("🗑️ Colección 'users' reiniciada.")

    password_admin = hash_password("123456")
    
    admin_user = {
        "username": "emiliano",
        "email": "emiliano@example.com",
        "full_name": "Emiliano (Admin)",
        "hashed_password": password_admin,
        "role": "super_admin",
        "status": "activo",
        "is_verified": True,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    await db["users"].insert_one(admin_user)
    print("👑 Usuario 'emiliano' recreado como Super Admin.")

    print("\n✨ Base de datos lista para pruebas desde cero.")
    print("-" * 30)
    print("ACCESO:")
    print("Usuario: emiliano")
    print("Password: 123456")
    print("-" * 30)

    client.close()

if __name__ == "__main__":
    asyncio.run(clear())
