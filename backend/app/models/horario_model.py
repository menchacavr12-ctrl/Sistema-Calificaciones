from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, time
from enum import Enum


class Horario(BaseModel):
    """Un horario semanal completo (por semestre)"""
    id: Optional[str] = None
    alumno_id: str
    semestre: int
    grupo: str
    año_escolar: str             # Ej: "2024-2025"
    materias: List[dict] = []   # Lista de bloques: {materia, dia, hora_inicio, hora_fin, salon, maestro}
    is_active: bool = True       # True = es el horario actual
    created_at: datetime = Field(default_factory=datetime.utcnow)


class BloqueHorario(BaseModel):
    materia: str
    dia: str           # "Lunes", "Martes", etc.
    hora_inicio: str   # "08:00"
    hora_fin: str      # "09:00"
    salon: Optional[str] = None
    maestro_id: Optional[str] = None
    maestro_nombre: Optional[str] = None
