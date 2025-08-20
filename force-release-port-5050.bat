@echo off
echo ========================================
echo Forcando liberacao da porta 5050
echo ========================================
echo.

echo Parando servicos de rede...
net stop dnscache /y >nul 2>&1
net stop netprofm /y >nul 2>&1

echo.
echo Aguardando 5 segundos...
timeout /t 5 /nobreak >nul

echo.
echo Iniciando servicos de rede...
net start dnscache >nul 2>&1
net start netprofm >nul 2>&1

echo.
echo Verificando se a porta 5050 foi liberada...
netstat -ano | findstr :5050

echo.
echo ========================================
echo Processo concluido!
echo ========================================
echo.
echo Se a porta ainda estiver sendo usada,
echo pode ser necessario reiniciar o computador.
echo.
pause
