import asyncio
import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

# Cargar configuración
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "calificaciones_db")

async def cleanup():
    print(f"🧹 Iniciando limpieza de campos nulos en {MONGO_DB_NAME}...")
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[MONGO_DB_NAME]

    # Lista de campos que suelen aparecer como null y queremos eliminar si no tienen valor
    fields_to_check = [
        "google_id", 
        "verification_code", 
        "verification_code_expiry",
        "numero_control",
        "semestre",
        "grupo",
        "especialidad",
        "departamento",
        "profile_picture"
    ]

    # 1. Limpiar la colección 'users'
    users_cursor = db["users"].find({})
    cleaned_count = 0

    async for user in users_cursor:
        unsets = {}
        for field in fields_to_check:
            # Si el campo existe y es null (None en Python)
            if field in user and user[field] is None:
                unsets[field] = ""
        
        if unsets:
            await db["users"].update_one(
                {"_id": user["_id"]},
                {"$unset": unsets}
            )
            cleaned_count += 1
            print(f"✅ Campos nulos eliminados para el usuario: {user.get('username', 'ID:' + str(user['_id']))}")

    print(f"\n✨ Limpieza terminada. Se procesaron {cleaned_count} usuarios.")
    client.close()

if __name__ == "__main__":
    asyncio.run(cleanup())
