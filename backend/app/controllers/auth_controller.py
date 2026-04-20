from datetime import datetime, timedelta
from fastapi import HTTPException, status
from bson import ObjectId
from app.config.database import get_db
from app.config.settings import VERIFICATION_CODE_EXPIRE_MINUTES
from app.utils.jwt_handler import hash_password, verify_password, create_access_token
from app.utils.helpers import serialize_doc
from app.models.user_model import UserCreate, UserLogin
import httpx

async def register_user(user_data: UserCreate) -> dict:
    db = get_db()

    if user_data.password != user_data.confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Las contraseñas no coinciden"
        )

    existing_email = await db["users"].find_one({"email": user_data.email})
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ya existe una cuenta con este correo electrónico"
        )

    existing_username = await db["users"].find_one({"username": user_data.username})
    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Este nombre de usuario ya está en uso"
        )

    new_user = {
        "username": user_data.username,
        "email": user_data.email,
        "full_name": user_data.full_name or user_data.username,
        "hashed_password": hash_password(user_data.password),
        "role": "alumno",
        "status": "activo",
        "is_verified": True,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }

    result = await db["users"].insert_one(new_user)

    return {
        "message": "Usuario registrado exitosamente.",
        "user_id": str(result.inserted_id)
    }

async def login_user(data: UserLogin) -> dict:
    db = get_db()

    user = await db["users"].find_one({
        "$or": [
            {"email": data.email_or_username},
            {"username": data.email_or_username}
        ]
    })

    if not user:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    if not user.get("hashed_password"):
        raise HTTPException(status_code=400, detail="Esta cuenta usa inicio de sesión con Google")

    if not verify_password(data.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    if user.get("status") == "suspendido" or user.get("status") == "inactivo":
        raise HTTPException(status_code=403, detail="Tu cuenta ha sido dada de baja o suspendida")

    token = create_access_token({"sub": str(user["_id"]), "role": user["role"]})
    user["id"] = str(user["_id"])

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": serialize_doc(user)
    }

