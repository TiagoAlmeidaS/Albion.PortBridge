# Script para parar e desabilitar o serviço CDPSvc
# Execute como administrador para ter sucesso completo

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Parando e desabilitando o serviço CDPSvc" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se estamos executando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "AVISO: Este script deve ser executado como administrador!" -ForegroundColor Yellow
    Write-Host "Clique com o botão direito no PowerShell e selecione 'Executar como administrador'" -ForegroundColor Yellow
    Write-Host ""
}

# Verificar status atual do serviço
Write-Host "Verificando status do serviço CDPSvc..." -ForegroundColor Green
try {
    $service = Get-Service -Name "CDPSvc" -ErrorAction Stop
    Write-Host "Status atual: $($service.Status)" -ForegroundColor White
    Write-Host "Tipo de inicialização: $($service.StartType)" -ForegroundColor White
} catch {
    Write-Host "Erro ao obter informações do serviço: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Tentar parar o serviço
Write-Host "Tentando parar o serviço CDPSvc..." -ForegroundColor Green
try {
    Stop-Service -Name "CDPSvc" -Force -ErrorAction Stop
    Write-Host "Serviço parado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao parar o serviço: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Aguardar um pouco
Write-Host "Aguardando 5 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Tentar desabilitar o serviço
Write-Host "Tentando desabilitar o serviço CDPSvc..." -ForegroundColor Green
try {
    Set-Service -Name "CDPSvc" -StartupType Disabled -ErrorAction Stop
    Write-Host "Serviço desabilitado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao desabilitar o serviço: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Verificar se a porta 5050 foi liberada
Write-Host "Verificando se a porta 5050 foi liberada..." -ForegroundColor Green
$portCheck = netstat -ano | Select-String ":5050"

if ($portCheck) {
    Write-Host "AVISO: A porta 5050 ainda está sendo usada!" -ForegroundColor Red
    Write-Host $portCheck -ForegroundColor White
} else {
    Write-Host "SUCESSO: A porta 5050 foi liberada!" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Processo concluído!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($portCheck) {
    Write-Host "Recomendações:" -ForegroundColor Yellow
    Write-Host "1. Execute este script como administrador" -ForegroundColor White
    Write-Host "2. Reinicie o computador" -ForegroundColor White
    Write-Host "3. Verifique se há outros serviços dependentes" -ForegroundColor White
}

Write-Host ""
Read-Host "Pressione Enter para sair"
