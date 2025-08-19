@echo off
echo ========================================
echo    Download FRP - Albion.PortBridge
echo ========================================
echo.
echo Baixando FRP para Windows...
echo.

REM Define a versão do FRP
set FRP_VERSION=v0.51.3

REM Cria pasta temporária
if not exist "temp" mkdir temp
cd temp

REM Baixa o FRP
echo Baixando FRP %FRP_VERSION%...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/fatedier/frp/releases/download/%FRP_VERSION%/frp_%FRP_VERSION%_windows_amd64.zip' -OutFile 'frp.zip'"

if not exist "frp.zip" (
    echo ❌ Erro ao baixar FRP
    pause
    exit /b 1
)

REM Extrai o arquivo
echo Extraindo arquivos...
powershell -Command "Expand-Archive -Path 'frp.zip' -DestinationPath '.' -Force"

REM Copia os executáveis para a pasta pai
echo Copiando executaveis...
copy "frp_%FRP_VERSION%_windows_amd64\frps.exe" "..\frps.exe"
copy "frp_%FRP_VERSION%_windows_amd64\frpc.exe" "..\frpc.exe"

REM Volta para a pasta pai
cd ..

REM Limpa arquivos temporários
rmdir /s /q temp

echo.
echo ========================================
echo ✅ FRP instalado com sucesso!
echo.
echo Arquivos disponiveis:
echo - frps.exe (Servidor)
echo - frpc.exe (Cliente)
echo.
echo Execute run-frps.bat para iniciar o servidor
echo Execute run-frpc.bat para iniciar o cliente
echo.
pause
