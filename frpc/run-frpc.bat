@echo off
echo ========================================
echo    FRP Client - Albion.PortBridge
echo ========================================
echo.
echo Conectando ao servidor FRP...
echo Servidor: 192.168.18.31:6000
echo Tunneling: 127.0.0.1:5050 -> 15151/UDP
echo.
echo Pressione Ctrl+C para parar
echo.

REM Verifica se o frpc.exe existe
if not exist "frpc.exe" (
    echo ERRO: frpc.exe nao encontrado!
    echo Baixe o FRP de: https://github.com/fatedier/frp/releases
    echo Extraia e copie frpc.exe para esta pasta
    pause
    exit /b 1
)

REM Inicia o cliente FRP
frpc.exe -c frpc.ini

pause
