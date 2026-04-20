from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.utils.jwt_handler import decode_token
from app.config.database import get_db
from bson import ObjectId

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_token(token)
    if not payload:
        raise credentials_exception

    user_id: str = payload.get("sub")
    if not user_id:
        raise credentials_exception

    db = get_db()
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user:
        raise credentials_exception

    if user.get("status") == "suspendido" or user.get("status") == "inactivo":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tu cuenta ha sido suspendida. Contacta al administrador."
        )

    user["id"] = str(user["_id"])
    return user

def require_role(*roles: str):
    """Dependency factory para requerir roles específicos"""
    async def role_checker(current_user: dict = Depends(get_current_user)):
        if current_user.get("role") not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"No tienes permiso para realizar esta acción. Se requiere: {', '.join(roles)}"
            )
        return current_user
    return role_checker

require_alumno = require_role("alumno")
require_maestro = require_role("maestro", "admin", "super_admin")
require_admin = require_role("admin", "super_admin")
require_super_admin = require_role("super_admin")
