@echo off
echo ========================================
echo    Setup FRP - Albion.PortBridge
echo ========================================
echo.
echo Este script configura o ambiente FRP UDP
echo para suporte a Albion Online na rede local.
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
echo    CONFIGURAÇÃO MANUAL NECESSÁRIA
echo ========================================
echo.
echo 1️⃣  NO SEGUNDO PC (servidor intermediário):
echo    - Copie a pasta 'frps' para o segundo PC
echo    - Execute: cd frps && install-frp.bat
echo    - Execute: run-frps.bat
echo.
echo 2️⃣  NA MÁQUINA PRINCIPAL (com Crypto):
echo    - Execute: cd frpc && install-frp.bat
echo    - Edite frpc.ini com o IP do segundo PC
echo    - Execute: run-frpc.bat
echo.
echo 3️⃣  TESTE A CONECTIVIDADE:
echo    - Execute: make test-udp
echo    - Ou: cd test && python test-udp.py
echo.
echo ========================================
echo.
echo 💡 Dica: Use 'make frp-setup' para ver os comandos novamente
echo.
pause
