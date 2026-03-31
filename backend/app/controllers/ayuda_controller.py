from app.config.database import get_db
from app.utils.helpers import serialize_list
from app.models.ayuda_model import ChatMessageCreate, ChatMessageInDB
from datetime import datetime

async def send_message_from_alumno(data: ChatMessageCreate, usuario_id: str) -> dict:
    db = get_db()
    msg = ChatMessageInDB(
        texto=data.texto,
        alumno_id=usuario_id,
        emisor_id=usuario_id,
        emisor_rol="alumno",
        leido=False # Admins haven't read it
    )
    await db["ayuda"].insert_one(msg.model_dump())
    return {"message": "Mensaje enviado exitosamente"}

async def send_message_from_admin(data: ChatMessageCreate, alumno_id: str, admin_id: str, admin_rol: str) -> dict:
    db = get_db()
    msg = ChatMessageInDB(
        texto=data.texto,
        alumno_id=alumno_id,
        emisor_id=admin_id,
        emisor_rol=admin_rol,
        leido=False # Alumno hasn't read it
    )
    await db["ayuda"].insert_one(msg.model_dump())
    return {"message": "Respuesta enviada"}

async def get_chat_for_alumno(alumno_id: str) -> list:
    db = get_db()
    mensajes_cursor = db["ayuda"].find({"alumno_id": alumno_id}).sort("fecha", 1)
    mensajes = await mensajes_cursor.to_list(1000)
    return serialize_list(mensajes)

async def mark_messages_as_read(alumno_id: str, read_by: str):
    """
    Si read_by == 'admin', marcamos como leídos los mensajes que mandó el 'alumno'.
    Si read_by == 'alumno', marcamos como leídos los mensajes que mandó el 'admin' o 'super_admin'.
    """
    db = get_db()
    if read_by == "admin":
        await db["ayuda"].update_many(
            {"alumno_id": alumno_id, "emisor_rol": "alumno", "leido": False},
            {"$set": {"leido": True}}
        )
    elif read_by == "alumno":
        await db["ayuda"].update_many(
            {"alumno_id": alumno_id, "emisor_rol": {"$in": ["admin", "super_admin"]}, "leido": False},
            {"$set": {"leido": True}}
        )
