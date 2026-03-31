from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config.database import connect_db, close_db
from app.config.settings import APP_NAME, APP_VERSION, DEBUG
from app.routes import auth_routes, clase_routes, usuario_routes, ayuda_routes, admin_routes, horario_routes
import os


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await connect_db()
    yield
    # Shutdown
    await close_db()


app = FastAPI(
    title=APP_NAME,
    version=APP_VERSION,
    description="API REST para el Sistema de Calificaciones EmilianitoProGamer",
    debug=DEBUG,
    lifespan=lifespan
)

# ─── CORS (permitir conexiones desde Flutter/Chrome/Android) ──────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # En producción: cambia a tu dominio
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── RUTAS ────────────────────────────────────────────────────────────────────
app.include_router(auth_routes.router)
app.include_router(clase_routes.router)
app.include_router(usuario_routes.router)
app.include_router(ayuda_routes.router)
app.include_router(admin_routes.router)
app.include_router(horario_routes.router)

# ─── ARCHIVOS ESTÁTICOS ───────────────────────────────────────────────────────
os.makedirs("uploads/profiles", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


# ─── RUTA RAÍZ ────────────────────────────────────────────────────────────────
@app.get("/", tags=["Root"])
async def root():
    return {
        "app": APP_NAME,
        "version": APP_VERSION,
        "status": "🟢 API corriendo correctamente",
        "docs": "/docs",
        "redoc": "/redoc"
    }
