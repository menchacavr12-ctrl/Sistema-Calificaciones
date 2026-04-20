import random
import string

def generate_class_code(length: int = 6) -> str:
    """Genera un código alfanumérico único para unirse a una clase. Ej: A3B9X2"""
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choices(chars, k=length))

def serialize_doc(doc: dict) -> dict:
    """Convierte un documento MongoDB (con _id) a dict con 'id' como string"""
    if doc and "_id" in doc:
        doc["id"] = str(doc["_id"])
        del doc["_id"]
    return doc

def serialize_list(docs: list) -> list:
    return [serialize_doc(doc) for doc in docs]
