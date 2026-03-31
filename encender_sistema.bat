@echo off
title Iniciando Sistema de Calificaciones...
echo [1/2] Iniciando Backend de FastAPI...
start powershell -NoExit -Command "cd backend; .\venv\Scripts\activate; uvicorn main:app --reload --host 0.0.0.0 --port 8000"

echo [2/2] Iniciando Frontend de Flutter...
start powershell -NoExit -Command "cd frontend; flutter run -d chrome"

echo.
echo ==============================================
echo [✅] ¡Sistema en proceso de inicio!
echo Las terminales se abrirán por separado.
echo Una vez que veas "INFO: Application startup complete" 
echo y "Flutter run on Chrome", ¡ya puedes usarlo!
echo ==============================================
pause
