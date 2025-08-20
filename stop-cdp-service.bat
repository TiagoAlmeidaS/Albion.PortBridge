@echo off
echo ========================================
echo Parando e desabilitando o servico CDPSvc
echo ========================================
echo.

echo Verificando se o servico CDPSvc esta rodando...
sc query CDPSvc

echo.
echo Parando o servico CDPSvc...
sc stop CDPSvc

echo.
echo Aguardando 3 segundos...
timeout /t 3 /nobreak >nul

echo.
echo Desabilitando o servico CDPSvc...
sc config CDPSvc start= disabled

echo.
echo Verificando se a porta 5050 foi liberada...
netstat -ano | findstr :5050

echo.
echo ========================================
echo Processo concluido!
echo ========================================
echo.
echo Se a porta 5050 ainda estiver sendo usada,
echo pode ser necessario reiniciar o computador
echo ou executar este script como administrador.
echo.
pause
