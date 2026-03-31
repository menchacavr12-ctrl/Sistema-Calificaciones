from fastapi import APIRouter, Depends
from app.models.ayuda_model import ChatMessageCreate
from app.controllers import ayuda_controller
from app.middlewares.auth_middleware import get_current_user

router = APIRouter(prefix="/api/ayuda", tags=["Ayuda/Chat"])

@router.post("/chat", summary="Enviar mensaje al soporte (Alumno)")
async def send_help_message(data: ChatMessageCreate, current_user: dict = Depends(get_current_user)):
    return await ayuda_controller.send_message_from_alumno(data, current_user["id"])

@router.get("/chat", summary="Obtener historial de chat (Alumno)")
async def get_my_chat(current_user: dict = Depends(get_current_user)):
    # Marcar leídos porque el alumno acaba de abrirlo
    await ayuda_controller.mark_messages_as_read(current_user["id"], read_by="alumno")
    return await ayuda_controller.get_chat_for_alumno(current_user["id"])
