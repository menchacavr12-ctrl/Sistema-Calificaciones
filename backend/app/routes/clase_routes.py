from fastapi import APIRouter, Depends, HTTPException
from app.models.clase_model import ClaseCreate, ClaseUpdate, JoinClaseRequest, CalificacionUpdate
from app.controllers import clase_controller
from app.middlewares.auth_middleware import get_current_user
from pydantic import BaseModel

router = APIRouter(prefix="/api/clases", tags=["Clases"])

@router.get("/mis-clases")
async def mis_clases_alumno(current_user: dict = Depends(get_current_user)):
    return await clase_controller.get_clases_alumno(current_user["id"])

@router.post("/unirse")
async def unirse_clase(data: JoinClaseRequest, current_user: dict = Depends(get_current_user)):
    return await clase_controller.join_clase(data, current_user["id"])

@router.get("/historial")
async def historial_academico(current_user: dict = Depends(get_current_user)):
    return await clase_controller.get_historial_academico(current_user["id"])

@router.post("/", status_code=201)
async def create_clase(data: ClaseCreate, current_user: dict = Depends(get_current_user)):
    if current_user.get("role") != "maestro":
        raise HTTPException(status_code=403, detail="Solo los maestros pueden crear clases")
    return await clase_controller.create_clase(data, current_user)

@router.delete("/{clase_id}")
async def delete_clase(clase_id: str, current_user: dict = Depends(get_current_user)):
    if current_user.get("role") != "maestro":
        raise HTTPException(status_code=403, detail="Solo los maestros pueden eliminar clases")
    return await clase_controller.delete_clase(clase_id, current_user["id"])

@router.get("/maestro/mis-clases")
async def mis_clases_maestro(current_user: dict = Depends(get_current_user)):
    return await clase_controller.get_clases_maestro(current_user["id"])

@router.put("/{clase_id}")
async def editar_clase(clase_id: str, data: ClaseUpdate, current_user: dict = Depends(get_current_user)):
    return await clase_controller.update_clase(clase_id, data, current_user["id"])

@router.get("/{clase_id}/alumnos")
async def alumnos_en_clase(clase_id: str, current_user: dict = Depends(get_current_user)):
    return await clase_controller.get_alumnos_en_clase(clase_id, current_user["id"])

@router.put("/{clase_id}/alumnos/{alumno_id}/calificacion/{parcial}",
            summary="Actualizar calificación de un alumno (Maestro)")
async def actualizar_calificacion(
    clase_id: str,
    alumno_id: str,
    parcial: int,
    data: CalificacionUpdate,
    current_user: dict = Depends(get_current_user)
):
    return await clase_controller.update_calificacion(clase_id, alumno_id, parcial, data, current_user["id"])
