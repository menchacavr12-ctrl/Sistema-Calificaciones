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

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=6)
    confirm_password: str
    full_name: Optional[str] = None

class UserLogin(BaseModel):
    email_or_username: str
    password: str

class UserInDB(UserBase):
    id: Optional[str] = None
    hashed_password: Optional[str] = None
    google_id: Optional[str] = None
    numero_control: Optional[str] = None
    semestre: Optional[int] = None
    grupo: Optional[str] = None
    especialidad: Optional[str] = None
    departamento: Optional[str] = None

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

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserPublic
