from fastapi import HTTPException, status
from bson import ObjectId
from datetime import datetime
from app.config.database import get_db
from app.models.clase_model import ClaseCreate, ClaseUpdate, JoinClaseRequest, CalificacionUpdate
from app.utils.helpers import generate_class_code, serialize_doc, serialize_list


# ─── CREAR CLASE (Maestro) ────────────────────────────────────────────────────
async def create_clase(data: ClaseCreate, maestro: dict) -> dict:
    db = get_db()

    # Generar código único
    code = generate_class_code()
    while await db["clases"].find_one({"codigo_acceso": code}):
        code = generate_class_code()

    nueva_clase = {
        "nombre": data.nombre,
        "grupo": data.grupo,
        "semestre": data.semestre,
        "color": data.color or "#7C3AED",
        "maestro_id": maestro["id"],
        "codigo_acceso": code,
        "alumnos": [],
        "is_active": True,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }

    result = await db["clases"].insert_one(nueva_clase)
    clase = await db["clases"].find_one({"_id": result.inserted_id})
    return serialize_doc(clase)


# ─── VER MIS CLASES (Maestro) ─────────────────────────────────────────────────
async def get_clases_maestro(maestro_id: str) -> list:
    db = get_db()
    clases = await db["clases"].find({"maestro_id": maestro_id, "is_active": True}).to_list(100)
    
    maestro = await db["users"].find_one({"_id": ObjectId(maestro_id)})
    nombre_maestro = maestro.get("full_name", "Profesor") if maestro else "Profesor"
    
    resultado = []
    for c in clases:
        c["id"] = str(c.pop("_id"))
        c["total_alumnos"] = len(c.get("alumnos", []))
        c["maestro"] = nombre_maestro
        c["codigo"] = c.get("codigo_acceso", "")
        resultado.append(c)
    return resultado


# ─── ELIMINAR CLASE (Maestro) ───────────────────────────────────────────────────
async def delete_clase(clase_id: str, maestro_id: str) -> dict:
    db = get_db()
    
    if not ObjectId.is_valid(clase_id):
        raise HTTPException(status_code=400, detail="ID de clase inválido")
        
    clase = await db["clases"].find_one({"_id": ObjectId(clase_id), "is_active": True})
    if not clase:
        raise HTTPException(status_code=404, detail="Clase no encontrada")
        
    if clase.get("maestro_id") != maestro_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para eliminar esta clase")
        
    # Borrado lógico
    await db["clases"].update_one(
        {"_id": ObjectId(clase_id)},
        {"$set": {"is_active": False, "updated_at": datetime.utcnow()}}
    )
    return {"msg": "Clase eliminada exitosamente"}


# ─── VER MIS CLASES (Alumno) ──────────────────────────────────────────────────
async def get_clases_alumno(alumno_id: str) -> list:
    db = get_db()
    # Las clases donde el alumno está inscrito
    clases = await db["clases"].find({"alumnos": alumno_id, "is_active": True}).to_list(100)
    
    resultado = []
    for c in clases:
        c["id"] = str(c.pop("_id"))
        c["total_alumnos"] = len(c.get("alumnos", []))
        c["codigo"] = c.get("codigo_acceso", "")
        
        # Obtener nombre profesor
        maestro = await db["users"].find_one({"_id": ObjectId(c.get("maestro_id"))})
        c["maestro"] = maestro.get("full_name", "Profesor") if maestro else "Profesor"
        
        # Obtener promedio del alumno
        alumno_clase = await db["alumno_clases"].find_one({"alumno_id": alumno_id, "clase_id": c["id"]})
        c["mi_promedio"] = alumno_clase.get("promedio") if alumno_clase else 0
        c["parcial_actual"] = 1 # O calcular basado en fechas
        resultado.append(c)
        
    return resultado


# ─── UNIRSE A UNA CLASE (Alumno) ─────────────────────────────────────────────
async def join_clase(data: JoinClaseRequest, alumno_id: str) -> dict:
    db = get_db()

    clase = await db["clases"].find_one({"codigo_acceso": data.codigo_acceso.upper(), "is_active": True})
    if not clase:
        raise HTTPException(status_code=404, detail="Código de acceso inválido o la clase no existe")

    clase_id = str(clase["_id"])

    if alumno_id in clase.get("alumnos", []):
        raise HTTPException(status_code=400, detail="Ya estás inscrito en esta clase")

    # Agregar al alumno
    await db["clases"].update_one(
        {"_id": clase["_id"]},
        {"$push": {"alumnos": alumno_id}}
    )

    # Crear registro de calificaciones vacío
    alumno_clase = await db["alumno_clases"].find_one({
        "alumno_id": alumno_id, "clase_id": clase_id
    })
    if not alumno_clase:
        await db["alumno_clases"].insert_one({
            "alumno_id": alumno_id,
            "clase_id": clase_id,
            "calificaciones": [],
            "promedio": None,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        })

    return {"message": f"¡Te has unido a {clase['nombre']} exitosamente!"}


# ─── VER ALUMNOS EN UNA CLASE (Maestro) ──────────────────────────────────────
async def get_alumnos_en_clase(clase_id: str, maestro_id: str) -> list:
    db = get_db()

    clase = await db["clases"].find_one({"_id": ObjectId(clase_id), "maestro_id": maestro_id})
    if not clase:
        raise HTTPException(status_code=404, detail="Clase no encontrada o no tienes permiso")

    alumnos_ids = clase.get("alumnos", [])
    alumnos = []
    for aid in alumnos_ids:
        try:
            alumno = await db["users"].find_one({"_id": ObjectId(aid)})
            if alumno:
                alumno = serialize_doc(alumno)
                # Obtener calificaciones del alumno en esta clase
                registro = await db["alumno_clases"].find_one({
                    "alumno_id": aid, "clase_id": clase_id
                })
                alumno["calificaciones"] = registro.get("calificaciones", []) if registro else []
                alumno["promedio"] = registro.get("promedio") if registro else None
                alumnos.append(alumno)
        except Exception:
            continue

    return alumnos


# ─── ACTUALIZAR CALIFICACIÓN DE UN ALUMNO (Maestro) ───────────────────────────
async def update_calificacion(clase_id: str, alumno_id: str, parcial: int, data: CalificacionUpdate, maestro_id: str) -> dict:
    db = get_db()

    # Verificar que la clase pertenece al maestro
    clase = await db["clases"].find_one({"_id": ObjectId(clase_id), "maestro_id": maestro_id})
    if not clase:
        raise HTTPException(status_code=403, detail="No tienes permiso para modificar esta clase")

    registro = await db["alumno_clases"].find_one({
        "alumno_id": alumno_id, "clase_id": clase_id
    })
    if not registro:
        raise HTTPException(status_code=404, detail="El alumno no está inscrito en esta clase")

    # Buscar si el parcial ya existe
    calificaciones = registro.get("calificaciones", [])
    parcial_existente = False
    for cal in calificaciones:
        if cal["parcial"] == parcial:
            cal["valor"] = data.valor
            cal["fecha_asignacion"] = datetime.utcnow()
            parcial_existente = True
            break

    if not parcial_existente:
        calificaciones.append({
            "parcial": parcial,
            "valor": data.valor,
            "fecha_asignacion": datetime.utcnow()
        })

    # Calcular promedio
    valores = [c["valor"] for c in calificaciones if c.get("valor") is not None]
    promedio = round(sum(valores) / len(valores), 2) if valores else None

    await db["alumno_clases"].update_one(
        {"alumno_id": alumno_id, "clase_id": clase_id},
        {"$set": {
            "calificaciones": calificaciones,
            "promedio": promedio,
            "updated_at": datetime.utcnow()
        }}
    )

    return {"message": "Calificación actualizada", "promedio": promedio}


# ─── EDITAR CLASE (Maestro) ───────────────────────────────────────────────────
async def update_clase(clase_id: str, data: ClaseUpdate, maestro_id: str) -> dict:
    db = get_db()
    update_data = {k: v for k, v in data.dict().items() if v is not None}
    update_data["updated_at"] = datetime.utcnow()

    result = await db["clases"].update_one(
        {"_id": ObjectId(clase_id), "maestro_id": maestro_id},
        {"$set": update_data}
    )

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Clase no encontrada o sin permiso")

    clase = await db["clases"].find_one({"_id": ObjectId(clase_id)})
    return serialize_doc(clase)


# ─── HISTORIAL ACADÉMICO (Alumno) ─────────────────────────────────────────────
async def get_historial_academico(alumno_id: str) -> dict:
    db = get_db()

    registros = await db["alumno_clases"].find({"alumno_id": alumno_id}).to_list(500)
    historial = []

    for reg in registros:
        try:
            clase = await db["clases"].find_one({"_id": ObjectId(reg["clase_id"])})
            maestro = await db["users"].find_one({"_id": ObjectId(clase["maestro_id"])}) if clase else None
            historial.append({
                "clase_id": reg["clase_id"],
                "nombre_materia": clase["nombre"] if clase else "N/A",
                "grupo": clase["grupo"] if clase else "N/A",
                "semestre": clase["semestre"] if clase else None,
                "maestro": maestro.get("full_name", "N/A") if maestro else "N/A",
                "calificaciones": reg.get("calificaciones", []),
                "promedio": reg.get("promedio")
            })
        except Exception:
            continue

    # Estadísticas generales
    promedios = [h["promedio"] for h in historial if h["promedio"] is not None]
    promedio_general = round(sum(promedios) / len(promedios), 2) if promedios else None

    return {
        "historial": historial,
        "total_materias": len(historial),
        "promedio_general": promedio_general
    }


