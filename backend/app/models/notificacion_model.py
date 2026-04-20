from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum

class NotificacionTipo(str, Enum):
    MENSAJE = "mensaje"
    CALIFICACION = "calificacion"
    SISTEMA = "sistema"
    AYUDA = "ayuda"

class Notificacion(BaseModel):
    id: Optional[str] = None
    destinatario_id: str
    remitente_id: Optional[str] = None
    tipo: NotificacionTipo = NotificacionTipo.SISTEMA
    titulo: str
    mensaje: str
    leido: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)

class MensajeAyuda(BaseModel):
    """Mensajes del centro de ayuda (alumno -> maestro/admin)"""
    id: Optional[str] = None
    remitente_id: str
    destinatario_id: str
    contenido: str
    es_predeterminado: bool = False
    respondido: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)

class MensajeAyudaCreate(BaseModel):
    destinatario_id: str
    contenido: str
    es_predeterminado: bool = False

class OpinionMaestro(BaseModel):
    """Opinión/rating de un alumno sobre un maestro"""
    id: Optional[str] = None
    alumno_id: str
    maestro_id: str
    calificacion: float = Field(..., ge=0, le=10)
    comentario: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
