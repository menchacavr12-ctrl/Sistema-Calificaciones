from fastapi import APIRouter, Depends
from app.middlewares.auth_middleware import get_current_user, require_admin
from app.controllers import horario_controller
from app.controllers.horario_controller import HorarioBlockCreate, HorarioGroupCreate

router = APIRouter(prefix="/api/horarios", tags=["Horarios"])

@router.post("/grupo", status_code=201)
async def agregar_bloque_grupo(data: HorarioGroupCreate, current_user: dict = Depends(require_admin)):
    return await horario_controller.add_horario_group(data)

@router.get("/me")
async def mi_horario(current_user: dict = Depends(get_current_user)):
    return await horario_controller.get_my_horario(current_user["id"])

@router.get("/usuario/{user_id}")
async def horario_usuario(user_id: str, current_user: dict = Depends(require_admin)):
    return await horario_controller.get_user_horario(user_id)

@router.post("/usuario/{user_id}", status_code=201)
async def agregar_bloque(user_id: str, data: HorarioBlockCreate, current_user: dict = Depends(require_admin)):
    return await horario_controller.add_horario_block(user_id, data)

@router.delete("/{block_id}")
async def eliminar_bloque(block_id: str, current_user: dict = Depends(require_admin)):
    return await horario_controller.delete_horario_block(block_id)
