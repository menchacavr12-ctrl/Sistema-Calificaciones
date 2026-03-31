from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ChatMessageCreate(BaseModel):
    texto: str = Field(..., description="Contenido del mensaje")

class ChatMessageInDB(ChatMessageCreate):
    alumno_id: str = Field(..., description="ID del alumno dueño del chat")
    emisor_id: str = Field(..., description="ID de quien lo envió")
    emisor_rol: str = Field(..., description="Rol del emisor: alumno, admin o super_admin")
    fecha: datetime = Field(default_factory=datetime.utcnow)
    leido: bool = Field(False, description="Si el mensaje fue leído por la contraparte")
