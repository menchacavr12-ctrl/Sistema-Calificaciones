from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class UserRole(str, Enum):
    ALUMNO = "alumno"
    MAESTRO = "maestro"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"


class UserStatus(str, Enum):
    ACTIVE = "activo"
    SUSPENDED = "suspendido"


# ─── Modelo base (campos comunes) ───────────────────────────────────────────
class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    full_name: Optional[str] = None
    profile_picture: Optional[str] = None
    role: UserRole = UserRole.ALUMNO
    status: UserStatus = UserStatus.ACTIVE
    is_verified: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


# ─── Modelo para REGISTRO (recibe del cliente) ───────────────────────────────
class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=6)
    confirm_password: str
    full_name: Optional[str] = None


# ─── Modelo para LOGIN ────────────────────────────────────────────────────────
class UserLogin(BaseModel):
    email_or_username: str
    password: str


# ─── Modelo en DB (incluye hash de contraseña) ───────────────────────────────
class UserInDB(UserBase):
    id: Optional[str] = None
    hashed_password: Optional[str] = None
    google_id: Optional[str] = None
    # Datos adicionales por rol
    # Para alumnos: número de control, semestre, grupo
    numero_control: Optional[str] = None
    semestre: Optional[int] = None
    grupo: Optional[str] = None
    # Para maestros: especialidad, departamento
    especialidad: Optional[str] = None
    departamento: Optional[str] = None


# ─── Respuesta pública (sin datos sensibles) ─────────────────────────────────
class UserPublic(BaseModel):
    id: str
    username: str
    email: str
    full_name: Optional[str] = None
    profile_picture: Optional[str] = None
    role: UserRole
    status: UserStatus
    is_verified: bool
    created_at: datetime
    numero_control: Optional[str] = None
    semestre: Optional[int] = None
    grupo: Optional[str] = None
    especialidad: Optional[str] = None
    departamento: Optional[str] = None




# ─── Token de respuesta ───────────────────────────────────────────────────────
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserPublic
