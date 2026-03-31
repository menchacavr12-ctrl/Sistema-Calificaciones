from fastapi import APIRouter
from app.models.user_model import UserCreate, UserLogin
from app.controllers import auth_controller

router = APIRouter(prefix="/api/auth", tags=["Autenticación"])


@router.post("/register", summary="Registrar nuevo usuario")
async def register(user_data: UserCreate):
    return await auth_controller.register_user(user_data)


@router.post("/login", summary="Iniciar sesión")
async def login(data: UserLogin):
    return await auth_controller.login_user(data)
