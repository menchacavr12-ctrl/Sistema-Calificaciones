from fastapi import HTTPException
from pydantic import BaseModel, Field
from app.config.database import get_db
from bson import ObjectId
from app.utils.helpers import serialize_list

class HorarioBlockCreate(BaseModel):
    dia: str = Field(..., description="Día de la semana (Lunes, Martes...)")
    hora: str = Field(..., description="Rango de horario, ej: 08:00 - 09:00")
    materia: str = Field(..., description="Nombre de la sub-clase o materia")
    maestro: str = Field(..., description="Nombre del maestro o encargado")
    aula: str = Field(..., description="Lugar físico donde se imparte")
    color: str = Field("#7C3AED", description="Color representativo en hex (#RRGGBB)")

class HorarioGroupCreate(HorarioBlockCreate):
    alumnos_ids: list[str] = Field(..., description="Lista de IDs de alumnos a asignar")

async def get_my_horario(user_id: str):
    db = get_db()

    blocks = await db["horarios"].find({"usuario_id": user_id}).to_list(1000)

    horario_dict = {
        'Lunes': [],
        'Martes': [],
        'Miércoles': [],
        'Jueves': [],
        'Viernes': []
    }

    for block in blocks:
        raw_dia = block.get("dia", "Lunes")
        dia = raw_dia.capitalize().strip()
        if dia == "Miercoles": dia = "Miércoles"

        if dia in horario_dict:
            horario_dict[dia].append({
                "id": str(block["_id"]),
                "hora": block.get("hora"),
                "materia": block.get("materia"),
                "maestro": block.get("maestro"),
                "aula": block.get("aula"),
                "color": block.get("color")
            })

    return horario_dict

async def get_user_horario(target_id: str):
    return await get_my_horario(target_id) # Reuse the same logic since target_id == user_id

async def add_horario_block(target_id: str, data: HorarioBlockCreate):
    db = get_db()
    block = data.model_dump()
    block["usuario_id"] = target_id
    res = await db["horarios"].insert_one(block)
    return {"message": "Bloque añadido", "id": str(res.inserted_id)}

async def delete_horario_block(block_id: str):
    db = get_db()
    res = await db["horarios"].delete_one({"_id": ObjectId(block_id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Bloque de horario no encontrado")
    return {"message": "Bloque eliminado"}

async def add_horario_group(data: HorarioGroupCreate):
    db = get_db()
    if not data.alumnos_ids:
        raise HTTPException(status_code=400, detail="Debe proporcionar al menos un ID de alumno")

    base_block = {
        "dia": data.dia,
        "hora": data.hora,
        "materia": data.materia,
        "maestro": data.maestro,
        "aula": data.aula,
        "color": data.color
    }

    docs_to_insert = []
    for alumno_id in data.alumnos_ids:
        block_for_user = base_block.copy()
        block_for_user["usuario_id"] = alumno_id
        docs_to_insert.append(block_for_user)

    if docs_to_insert:
        await db["horarios"].insert_many(docs_to_insert)

    return {"message": f"Bloque añadido a {len(docs_to_insert)} alumnos"}
