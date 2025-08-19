@echo off
echo ========================================
echo    FRP Server - Albion.PortBridge
echo ========================================
echo.
echo Iniciando servidor FRP UDP...
echo Porta: 6000/UDP
echo Dashboard: http://localhost:7500
echo.
echo Pressione Ctrl+C para parar
echo.

REM Verifica se o frps.exe existe
if not exist "frps.exe" (
    echo ERRO: frps.exe nao encontrado!
    echo Baixe o FRP de: https://github.com/fatedier/frp/releases
    echo Extraia e copie frps.exe para esta pasta
    pause
    exit /b 1
)

REM Inicia o servidor FRP
frps.exe -c frps.ini

pause
