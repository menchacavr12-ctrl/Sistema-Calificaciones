from fastapi import HTTPException
from app.config.database import get_db
from bson import ObjectId
from app.utils.helpers import serialize_list, serialize_doc

async def get_all_users():
    db = get_db()
    users = await db["users"].find(
        {},
        {"hashed_password": 0, "verification_code": 0}
    ).to_list(1000)
    return serialize_list(users)

async def change_user_status(target_id: str, new_status: str, current_user: dict):
    db = get_db()
    target_user = await db["users"].find_one({"_id": ObjectId(target_id)})

    if not target_user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    target_role = target_user.get("role")
    my_role = current_user.get("role")

    if target_role == "super_admin" and my_role != "super_admin":
        raise HTTPException(status_code=403, detail="No puedes modificar a un Súper Administrador")

    if target_role == "admin" and my_role != "super_admin":
        raise HTTPException(status_code=403, detail="No tienes permisos para modificar a otro Administrador")

    if str(target_user["_id"]) == str(current_user["_id"]):
        raise HTTPException(status_code=400, detail="No puedes modificarte a ti mismo desde aquí")

    await db["users"].update_one(
        {"_id": ObjectId(target_id)},
        {"$set": {"status": new_status}}
    )
    return {"message": f"Estado cambiado a {new_status}"}

async def change_user_role(target_id: str, new_role: str, current_user: dict):
    db = get_db()
    target_user = await db["users"].find_one({"_id": ObjectId(target_id)})

    if not target_user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if current_user.get("role") != "super_admin":
        raise HTTPException(status_code=403, detail="Solo Súper Administrador puede cambiar roles")

    if str(target_user["_id"]) == str(current_user["_id"]):
        raise HTTPException(status_code=400, detail="No puedes cambiar tu propio rol")

    await db["users"].update_one(
        {"_id": ObjectId(target_id)},
        {"$set": {"role": new_role}}
    )
    return {"message": f"Rol cambiado a {new_role}"}

async def get_students_chat_list():
    db = get_db()
    alumnos_cursor = db["users"].find({"role": "alumno"})
    alumnos = await alumnos_cursor.to_list(1000)

    chat_list = []
    for alumno in alumnos:
        alumno_id = str(alumno["_id"])

        unread_count = await db["ayuda"].count_documents({
            "alumno_id": alumno_id,
            "emisor_rol": "alumno",
            "leido": False
        })

        chat_list.append({
            "usuario_id": alumno_id,
            "usuario_nombre": alumno.get("full_name", alumno.get("username")),
            "usuario_email": alumno.get("email"),
            "unread_count": unread_count
        })

    chat_list.sort(key=lambda x: (-x["unread_count"], x["usuario_nombre"].lower()))
    return chat_list

async def get_maestro_opiniones(maestro_id: str):
    db = get_db()
    opiniones = await db["opiniones"].find({"maestro_id": maestro_id}).to_list(1000)
    for op in opiniones:
        alumno = await db["users"].find_one({"_id": ObjectId(op["alumno_id"])}, {"username": 1})
        if alumno:
            op["alumno_nombre"] = alumno.get("username", "Desconocido")
    return serialize_list(opiniones)

async def delete_opinion(opinion_id: str):
    db = get_db()
    res = await db["opiniones"].delete_one({"_id": ObjectId(opinion_id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Reseña no encontrada")
    return {"message": "Reseña eliminada permanentemente"}
