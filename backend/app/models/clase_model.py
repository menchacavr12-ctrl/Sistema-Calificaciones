from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


# ─── Modelos de Horario ────────────────────────────────────────────────────────
class HorarioItem(BaseModel):
    dia: int = Field(..., description="1=Lunes, 2=Martes... 5=Viernes")
    hora_inicio: str = Field(..., description="Formato HH:MM, ej: '07:00'")
    hora_fin: str = Field(..., description="Formato HH:MM, ej: '08:00'")
    salon: Optional[str] = "Por definir"

# ─── Modelo de Clase/Materia ──────────────────────────────────────────────────
class ClaseBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=100)
    grupo: str = Field(..., min_length=1, max_length=10)   # Ej: "6°C"
    semestre: int = Field(..., ge=1, le=12)
    color: str = Field(default="#7C3AED")                  # Color hex de la tarjeta
    maestro_id: str
    codigo_acceso: Optional[str] = None                    # Código de 6 chars para unirse
    horarios: List[HorarioItem] = []                       # Lista de horarios en la semana
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class ClaseCreate(BaseModel):
    nombre: str
    grupo: str
    semestre: int
    color: Optional[str] = "#7C3AED"
    horarios: List[HorarioItem] = []


class ClaseUpdate(BaseModel):
    nombre: Optional[str] = None
    grupo: Optional[str] = None
    color: Optional[str] = None


class ClaseInDB(ClaseBase):
    id: Optional[str] = None
    alumnos: List[str] = []       # Lista de IDs de alumnos inscritos
    is_active: bool = True


class ClasePublic(BaseModel):
    id: str
    nombre: str
    grupo: str
    semestre: int
    color: str
    codigo_acceso: str
    maestro_id: str
    alumnos_count: int = 0
    is_active: bool
    horarios: List[HorarioItem] = []


# ─── Unirse a una clase ───────────────────────────────────────────────────────
class JoinClaseRequest(BaseModel):
    codigo_acceso: str


# ─── Calificaciones ───────────────────────────────────────────────────────────
class Calificacion(BaseModel):
    parcial: int       # 1, 2, 3...
    valor: Optional[float] = None   # None = PENDIENTE
    fecha_asignacion: Optional[datetime] = None


class CalificacionUpdate(BaseModel):
    valor: Optional[float] = Field(None, ge=0, le=100)


class AlumnoEnClase(BaseModel):
    """Relación alumno-clase con sus calificaciones"""
    alumno_id: str
    clase_id: str
    calificaciones: List[Calificacion] = []
    promedio: Optional[float] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
