import pymongo
import os

# Configuración
MONGO_URI = "mongodb+srv://alejandroemilianonunezme_db_user:Y8nrJYxbz1WLjw0E@cluster0.qdgjrgx.mongodb.net/calificaciones_db?retryWrites=true&w=majority"
RENDER_URL = "https://sistema-calificaciones-z8oy.onrender.com"
OLD_URL = "http://localhost:8000"

def migrate():
    print(f"🚀 Iniciando migración de fotos de perfil...")
    try:
        client = pymongo.MongoClient(MONGO_URI)
        db = client.get_default_database()
        users_col = db["users"]
        
        # Buscar todos los usuarios con foto de perfil que contengan localhost
        query = {"profile_picture": {"$regex": OLD_URL}}
        users_to_update = list(users_col.find(query))
        
        print(f"📦 Encontrados {len(users_to_update)} usuarios para actualizar.")
        
        count = 0
        for user in users_to_update:
            old_photo = user["profile_picture"]
            new_photo = old_photo.replace(OLD_URL, RENDER_URL)
            
            users_col.update_one(
                {"_id": user["_id"]},
                {"$set": {"profile_picture": new_photo}}
            )
            count += 1
            print(f"✅ Actualizado: {user.get('username', 'Sin nombre')} -> {new_photo}")
            
        print(f"🎉 Migración completada. total: {count} registros actualizados.")
        
    except Exception as e:
        print(f"❌ Error durante la migración: {e}")

if __name__ == "__main__":
    migrate()
