from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Request
from app.config.database import get_db
from app.middlewares.auth_middleware import get_current_user
from app.utils.helpers import serialize_doc, serialize_list
from bson import ObjectId
import os
import shutil
import uuid

router = APIRouter(prefix="/api/usuarios", tags=["Usuarios"])

@router.get("/me")
async def get_my_profile(current_user: dict = Depends(get_current_user)):
    # evitar mandar contraseñas
    current_user.pop("hashed_password", None)
    current_user.pop("verification_code", None)
    current_user.pop("verification_code_expiry", None)
    return serialize_doc(current_user)

@router.put("/me")
async def update_my_profile(data: dict, current_user: dict = Depends(get_current_user)):
    db = get_db()

    update_data = {}
    if "full_name" in data:
        update_data["full_name"] = data["full_name"]
    if "profile_picture" in data:
        update_data["profile_picture"] = data["profile_picture"]

    if update_data:
        from datetime import datetime
        update_data["updated_at"] = datetime.utcnow()
        await db["users"].update_one(
            {"_id": ObjectId(current_user["id"])},
            {"$set": update_data}
        )
        return {"message": "Perfíl actualizado"}
    return {"message": "Sin cambios"}

@router.post("/me/foto")
async def upload_profile_picture(request: Request, file: UploadFile = File(...), current_user: dict = Depends(get_current_user)):
    db = get_db()
    valid_exts = [".jpg", ".jpeg", ".png", ".gif", ".webp"]
    is_valid_ext = any(file.filename.lower().endswith(ext) for ext in valid_exts)
    is_valid_mime = file.content_type and file.content_type.startswith("image/")

    if not is_valid_ext and not is_valid_mime:
        raise HTTPException(status_code=400, detail="El archivo debe ser una imagen válida")

    ext = file.filename.split(".")[-1]
    new_filename = f"{current_user['id']}_{uuid.uuid4().hex[:8]}.{ext}"
    file_location = f"uploads/profiles/{new_filename}"

    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    base_url = str(request.base_url)
    image_url = f"{base_url}{file_location}"

    from datetime import datetime
    await db["users"].update_one(
        {"_id": ObjectId(current_user["id"])},
        {"$set": {"profile_picture": image_url, "updated_at": datetime.utcnow()}}
    )

    return {"message": "Foto subida exitosamente", "profile_picture": image_url}

@router.get("/maestros")
async def get_maestros(current_user: dict = Depends(get_current_user)):
    db = get_db()
    maestros = await db["users"].find(
        {"role": "maestro", "status": "activo"},
        {"hashed_password": 0, "verification_code": 0}
    ).to_list(200)

    for maestro in maestros:
        opiniones = await db["opiniones"].find({"maestro_id": str(maestro["_id"])}).to_list(1000)
        calificaciones = [o.get("calificacion", 0) for o in opiniones]
        maestro["rating"] = round(sum(calificaciones) / len(calificaciones), 2) if calificaciones else 0.0
        maestro["total_opiniones"] = len(opiniones)

    return serialize_list(maestros)

@router.get("/maestros/{maestro_id}")
async def get_maestro_detail(maestro_id: str, current_user: dict = Depends(get_current_user)):
    db = get_db()
    maestro = await db["users"].find_one(
        {"_id": ObjectId(maestro_id), "role": "maestro"},
        {"hashed_password": 0, "verification_code": 0}
    )
    if not maestro:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Maestro no encontrado")

    opiniones = await db["opiniones"].find({"maestro_id": maestro_id}).to_list(1000)
    calificaciones = [o.get("calificacion", 0) for o in opiniones]
    promedio_opinion = round(sum(calificaciones) / len(calificaciones), 2) if calificaciones else None

    maestro = serialize_doc(maestro)
    maestro["promedio_opinion"] = promedio_opinion
    maestro["total_opiniones"] = len(opiniones)
    maestro["opiniones"] = serialize_list(opiniones)
    return maestro

@router.post("/maestros/{maestro_id}/opinion")
async def opinar_maestro(maestro_id: str, data: dict, current_user: dict = Depends(get_current_user)):
    from datetime import datetime
    db = get_db()

    existente = await db["opiniones"].find_one({
        "alumno_id": current_user["id"],
        "maestro_id": maestro_id
    })

    if existente:
        await db["opiniones"].update_one(
            {"_id": existente["_id"]},
            {"$set": {
                "calificacion": data.get("calificacion"),
                "comentario": data.get("comentario"),
                "updated_at": datetime.utcnow()
            }}
        )
    else:
        await db["opiniones"].insert_one({
            "alumno_id": current_user["id"],
            "maestro_id": maestro_id,
            "calificacion": data.get("calificacion"),
            "comentario": data.get("comentario"),
            "created_at": datetime.utcnow()
        })

    return {"message": "Opinión registrada exitosamente"}

@router.get("/me/opiniones")
async def get_mis_opiniones(current_user: dict = Depends(get_current_user)):
    db = get_db()
    if current_user.get("role") != "maestro":
        raise HTTPException(status_code=403, detail="Solo los maestros pueden ver su bandeja de reseñas")

    opiniones = await db["opiniones"].find({"maestro_id": current_user["id"]}).to_list(1000)

    calificaciones = [o.get("calificacion", 0) for o in opiniones]
    promedio = round(sum(calificaciones) / len(calificaciones), 1) if calificaciones else 0.0

    return {
        "promedio": promedio,
        "total": len(opiniones),
        "reseñas": serialize_list(opiniones)
    }
