@echo off
echo ========================================
echo    Setup Receiver - Albion.PortBridge
echo ========================================
echo.
echo Este script configura SUA MAQUINA para
echo receber dados UDP do PC que roda o Crypto.
echo.

REM Verifica se está rodando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ ERRO: Execute este script como ADMINISTRADOR!
    echo.
    echo Clique com botão direito no script e selecione:
    echo "Executar como administrador"
    echo.
    pause
    exit /b 1
)

echo ✅ Executando como administrador
echo.

REM Obtém o IP da máquina atual
echo 🔍 Detectando IP da sua máquina...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set LOCAL_IP=%%a
    goto :found_ip
)
:found_ip
set LOCAL_IP=%LOCAL_IP: =%

echo ✅ IP detectado: %LOCAL_IP%
echo.

REM Cria arquivo .env se não existir
if not exist ".env" (
    echo 📝 Criando arquivo .env...
    copy "env.example" ".env"
    echo ⚠️  IMPORTANTE: Edite o arquivo .env com suas configurações!
    echo.
) else (
    echo ✅ Arquivo .env já existe
)

echo.
echo 🔧 Configurando regras de firewall...
call firewall-rules.bat

echo.
echo ========================================
echo    CONFIGURAÇÃO PARA SUA MÁQUINA
echo ========================================
echo.
echo 🎯 SUA MÁQUINA (receptora de dados):
echo    - IP: %LOCAL_IP%
echo    - Porta 6000/UDP: Aceita conexões FRP
echo    - Porta 15151/UDP: Recebe dados do túnel
echo    - Porta 7500/TCP: Dashboard de monitoramento
echo.
echo 📋 Execute na SUA MÁQUINA:
echo    cd frps
echo    install-frp.bat
echo    run-frps.bat
echo.
echo ========================================
echo    CONFIGURAÇÃO PARA O PC DO CRYPTO
echo ========================================
echo.
echo 🎯 PC DO CRYPTO (enviador de dados):
echo    - Copie a pasta 'frpc' para o PC do Crypto
echo    - Edite frpc.ini: server_addr = %LOCAL_IP%
echo    - Execute: cd frpc && install-frp.bat
echo    - Execute: run-frpc.bat
echo.
echo ========================================
echo.
echo 💡 Dica: Use 'make frp-setup' para ver os comandos novamente
echo.
pause
