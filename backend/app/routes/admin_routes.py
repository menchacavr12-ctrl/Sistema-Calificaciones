from fastapi import APIRouter, Depends, Query
from app.middlewares.auth_middleware import get_current_user, require_admin, require_super_admin
from app.controllers import admin_controller
from app.controllers import ayuda_controller
from app.models.ayuda_model import ChatMessageCreate

router = APIRouter(prefix="/api/admin", tags=["Administración"])

@router.get("/usuarios", summary="Ver todos los usuarios (Admin/SuperAdmin)")
async def ver_usuarios(current_user: dict = Depends(require_admin)):
    return await admin_controller.get_all_users()

@router.put("/usuarios/{target_id}/status", summary="Cambiar estado del usuario (Actuar como baja)")
async def cambiar_estado(target_id: str, status: str = Query(...), current_user: dict = Depends(require_admin)):
    return await admin_controller.change_user_status(target_id, status, current_user)

@router.put("/usuarios/{target_id}/role", summary="Promover/Degradar rol de usuario (Solo SuperAdmin)")
async def cambiar_rol(target_id: str, role: str = Query(...), current_user: dict = Depends(require_super_admin)):
    return await admin_controller.change_user_role(target_id, role, current_user)

@router.get("/chat/alumnos", summary="Obtener lista de alumnos con conteo de no leídos")
async def lista_chats(current_user: dict = Depends(require_admin)):
    return await admin_controller.get_students_chat_list()

@router.get("/chat/{alumno_id}", summary="Obtener historial de chat de un alumno concreto")
async def leer_historial_chat(alumno_id: str, current_user: dict = Depends(require_admin)):
    await ayuda_controller.mark_messages_as_read(alumno_id, read_by="admin")
    return await ayuda_controller.get_chat_for_alumno(alumno_id)

@router.post("/chat/{alumno_id}", summary="Enviar mensaje a un alumno como admin")
async def enviar_mensaje_admin(alumno_id: str, data: ChatMessageCreate, current_user: dict = Depends(require_admin)):
    return await ayuda_controller.send_message_from_admin(data, alumno_id, current_user["id"], current_user.get("role", "admin"))

@router.get("/maestros/{maestro_id}/opiniones", summary="Ver reseñas de un maestro revelando al autor")
async def ver_opiniones_maestro(maestro_id: str, current_user: dict = Depends(require_admin)):
    return await admin_controller.get_maestro_opiniones(maestro_id)

@router.delete("/opiniones/{opinion_id}", summary="Eliminar una reseña")
async def eliminar_opinion(opinion_id: str, current_user: dict = Depends(require_admin)):
    return await admin_controller.delete_opinion(opinion_id)
