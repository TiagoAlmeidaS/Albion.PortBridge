@echo off
echo ========================================
echo    Status Check - Albion.PortBridge
echo ========================================
echo.

echo 🔍 Verificando componentes do sistema...
echo.

REM Verifica se o FRP está instalado
echo 📦 FRP Installation:
if exist "frps\frps.exe" (
    echo   ✅ frps.exe encontrado
) else (
    echo   ❌ frps.exe não encontrado
)

if exist "frpc\frpc.exe" (
    echo   ✅ frpc.exe encontrado
) else (
    echo   ❌ frpc.exe não encontrado
)

echo.

REM Verifica se os serviços estão rodando
echo 🚀 Service Status:
netstat -an | findstr ":6000" >nul
if %errorlevel% equ 0 (
    echo   ✅ FRP Server (6000/UDP) - ATIVO
) else (
    echo   ❌ FRP Server (6000/UDP) - INATIVO
)

netstat -an | findstr ":15151" >nul
if %errorlevel% equ 0 (
    echo   ✅ FRP Tunnel (15151/UDP) - ATIVO
) else (
    echo   ❌ FRP Tunnel (15151/UDP) - INATIVO
)

netstat -an | findstr ":5050" >nul
if %errorlevel% equ 0 (
    echo   ✅ Local Service (5050/UDP) - ATIVO
) else (
    echo   ❌ Local Service (5050/UDP) - INATIVO
)

netstat -an | findstr ":7500" >nul
if %errorlevel% equ 0 (
    echo   ✅ FRP Dashboard (7500/TCP) - ATIVO
) else (
    echo   ❌ FRP Dashboard (7500/TCP) - INATIVO
)

echo.

REM Verifica arquivos de configuração
echo ⚙️  Configuration Files:
if exist "frps\frps.ini" (
    echo   ✅ frps.ini encontrado
) else (
    echo   ❌ frps.ini não encontrado
)

if exist "frpc\frpc.ini" (
    echo   ✅ frpc.ini encontrado
) else (
    echo   ❌ frpc.ini não encontrado
)

if exist ".env" (
    echo   ✅ .env encontrado
) else (
    echo   ❌ .env não encontrado
)

echo.

REM Verifica regras de firewall
echo 🔥 Firewall Rules:
netsh advfirewall firewall show rule name="FRPS UDP 6000" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ Regra UDP 6000 configurada
) else (
    echo   ❌ Regra UDP 6000 não configurada
)

netsh advfirewall firewall show rule name="FRPS UDP 15151" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ Regra UDP 15151 configurada
) else (
    echo   ❌ Regra UDP 15151 não configurada
)

echo.

REM Verifica conectividade de rede
echo 🌐 Network Connectivity:
echo   Testando conectividade para 192.168.18.31...
ping -n 1 192.168.18.31 >nul
if %errorlevel% equ 0 (
    echo   ✅ Rede acessível
) else (
    echo   ❌ Problema de conectividade de rede
)

echo.

echo ========================================
echo 📊 RESUMO DO STATUS:
echo ========================================

REM Conta componentes ativos
set /a active=0
set /a total=0

REM FRP executáveis
if exist "frps\frps.exe" set /a active+=1
if exist "frpc\frpc.exe" set /a active+=1
set /a total+=2

REM Serviços
netstat -an | findstr ":6000" >nul && set /a active+=1
netstat -an | findstr ":15151" >nul && set /a active+=1
netstat -an | findstr ":5050" >nul && set /a active+=1
netstat -an | findstr ":7500" >nul && set /a active+=1
set /a total+=4

REM Configurações
if exist "frps\frps.ini" set /a active+=1
if exist "frpc\frpc.ini" set /a active+=1
if exist ".env" set /a active+=1
set /a total+=3

REM Firewall
netsh advfirewall firewall show rule name="FRPS UDP 6000" >nul 2>&1 && set /a active+=1
netsh advfirewall firewall show rule name="FRPS UDP 15151" >nul 2>&1 && set /a active+=1
set /a total+=2

echo.
echo Componentes ativos: %active%/%total%
echo.

if %active% equ %total% (
    echo 🎉 SISTEMA 100%% FUNCIONAL!
    echo ✅ Todos os componentes estão ativos e configurados
) else if %active% gtr %total%*8/10 (
    echo 🟡 SISTEMA PARCIALMENTE FUNCIONAL
    echo ⚠️  Alguns componentes precisam de atenção
) else (
    echo 🚨 SISTEMA COM PROBLEMAS
    echo ❌ Muitos componentes não estão funcionando
)

echo.
echo 💡 Comandos úteis:
echo   - make frp-setup    : Instruções de configuração
echo   - make test-udp     : Testa conectividade UDP
echo   - setup-frp.bat     : Configuração automática
echo   - firewall-rules.bat: Configura firewall
echo.
pause
