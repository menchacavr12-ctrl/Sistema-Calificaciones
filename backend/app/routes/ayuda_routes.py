from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from app.models.ayuda_model import ChatMessageCreate
from app.controllers import ayuda_controller
from app.middlewares.auth_middleware import get_current_user
from app.config.database import get_db
from app.utils.helpers import serialize_doc
from typing import Dict, List
import json
from datetime import datetime

router = APIRouter(prefix="/api/ayuda", tags=["Ayuda/Chat"])

# ── Gestor de conexiones WebSocket ────────────────────────────────────────────
class ChatConnectionManager:
    def __init__(self):
        # { alumno_id: [ws1, ws2, ...] }  (puede haber alumno + admin en la misma sala)
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, alumno_id: str, websocket: WebSocket):
        await websocket.accept()
        if alumno_id not in self.active_connections:
            self.active_connections[alumno_id] = []
        self.active_connections[alumno_id].append(websocket)

    def disconnect(self, alumno_id: str, websocket: WebSocket):
        if alumno_id in self.active_connections:
            self.active_connections[alumno_id].remove(websocket)
            if not self.active_connections[alumno_id]:
                del self.active_connections[alumno_id]

    async def broadcast_to_room(self, alumno_id: str, message: dict):
        """Envía el mensaje a todos los que están en la sala del alumno."""
        if alumno_id in self.active_connections:
            data = json.dumps(message, default=str)
            dead = []
            for ws in self.active_connections[alumno_id]:
                try:
                    await ws.send_text(data)
                except Exception:
                    dead.append(ws)
            for ws in dead:
                self.active_connections[alumno_id].remove(ws)


manager = ChatConnectionManager()


# ── REST: Historial (para cargar al abrir el chat) ────────────────────────────
@router.post("/chat", summary="Enviar mensaje al soporte (Alumno) – REST fallback")
async def send_help_message(data: ChatMessageCreate, current_user: dict = Depends(get_current_user)):
    return await ayuda_controller.send_message_from_alumno(data, current_user["id"])

@router.get("/chat", summary="Obtener historial de chat (Alumno)")
async def get_my_chat(current_user: dict = Depends(get_current_user)):
    await ayuda_controller.mark_messages_as_read(current_user["id"], read_by="alumno")
    return await ayuda_controller.get_chat_for_alumno(current_user["id"])


# ── WebSocket: Alumno ─────────────────────────────────────────────────────────
@router.websocket("/ws/alumno/{alumno_id}")
async def ws_alumno(websocket: WebSocket, alumno_id: str):
    """
    El alumno se conecta a su propia sala usando su ID.
    """
    await manager.connect(alumno_id, websocket)
    db = get_db()
    try:
        while True:
            raw = await websocket.receive_text()
            data = json.loads(raw)
            texto = data.get("texto", "").strip()
            if not texto:
                continue

            msg = {
                "texto": texto,
                "alumno_id": alumno_id,
                "emisor_id": alumno_id,
                "emisor_rol": "alumno",
                "leido": False,
                "fecha": datetime.utcnow(),
            }
            result = await db["ayuda"].insert_one(msg)
            msg["_id"] = str(result.inserted_id)
            msg["fecha"] = msg["fecha"].isoformat()

            await manager.broadcast_to_room(alumno_id, msg)

    except WebSocketDisconnect:
        manager.disconnect(alumno_id, websocket)


# ── WebSocket: Admin ──────────────────────────────────────────────────────────
@router.websocket("/ws/admin/{alumno_id}")
async def ws_admin(websocket: WebSocket, alumno_id: str):
    """
    El admin se conecta a la sala del alumno especificado para responderle.
    Token se pasa como query param: ?token=<JWT>
    """
    await manager.connect(alumno_id, websocket)
    db = get_db()
    # Obtener admin_id desde query param opcional
    admin_id = websocket.query_params.get("admin_id", "admin")
    admin_rol = websocket.query_params.get("rol", "admin")
    try:
        while True:
            raw = await websocket.receive_text()
            data = json.loads(raw)
            texto = data.get("texto", "").strip()
            if not texto:
                continue

            msg = {
                "texto": texto,
                "alumno_id": alumno_id,
                "emisor_id": admin_id,
                "emisor_rol": admin_rol,
                "leido": False,
                "fecha": datetime.utcnow(),
            }
            result = await db["ayuda"].insert_one(msg)
            msg["_id"] = str(result.inserted_id)
            msg["fecha"] = msg["fecha"].isoformat()

            await manager.broadcast_to_room(alumno_id, msg)

    except WebSocketDisconnect:
        manager.disconnect(alumno_id, websocket)
