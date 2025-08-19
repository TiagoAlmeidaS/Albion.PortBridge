@echo off
echo ========================================
echo    Firewall Rules - Albion.PortBridge
echo ========================================
echo.
echo Adicionando regras de firewall para FRP UDP...
echo.

REM Adiciona regra para porta 6000/UDP (frps)
netsh advfirewall firewall add rule name="FRPS UDP 6000" dir=in action=allow protocol=UDP localport=6000
if %errorlevel% equ 0 (
    echo ✅ Regra para porta 6000/UDP adicionada
) else (
    echo ❌ Erro ao adicionar regra para porta 6000/UDP
)

REM Adiciona regra para porta 15151/UDP (túnel)
netsh advfirewall firewall add rule name="FRPS UDP 15151" dir=in action=allow protocol=UDP localport=15151
if %errorlevel% equ 0 (
    echo ✅ Regra para porta 15151/UDP adicionada
) else (
    echo ❌ Erro ao adicionar regra para porta 15151/UDP
)

REM Adiciona regra para porta 7500/TCP (dashboard)
netsh advfirewall firewall add rule name="FRPS Dashboard 7500" dir=in action=allow protocol=TCP localport=7500
if %errorlevel% equ 0 (
    echo ✅ Regra para porta 7500/TCP (dashboard) adicionada
) else (
    echo ❌ Erro ao adicionar regra para porta 7500/TCP
)

echo.
echo ========================================
echo Regras de firewall configuradas!
echo.
echo Portas liberadas:
echo - 6000/UDP (Servidor FRP)
echo - 15151/UDP (Túnel UDP)
echo - 7500/TCP (Dashboard)
echo.
echo Pressione qualquer tecla para sair...
pause >nul
