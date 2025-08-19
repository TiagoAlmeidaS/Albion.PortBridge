# Script PowerShell para iniciar o Albion.PortBridge
# Execute como Administrador se necessário

Write-Host "🚀 Albion.PortBridge - Script de Inicialização" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Verifica se o Docker está rodando
Write-Host "🔍 Verificando Docker..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✅ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker não está rodando. Inicie o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

# Verifica se o arquivo .env existe
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  Arquivo .env não encontrado. Copiando de env.example..." -ForegroundColor Yellow
    Copy-Item "env.example" ".env"
    Write-Host "📝 Edite o arquivo .env com suas configurações antes de continuar." -ForegroundColor Yellow
    Write-Host "   Especialmente o NGROK_AUTHTOKEN!" -ForegroundColor Red
    pause
}

# Lê configurações do .env
$envContent = Get-Content ".env" | Where-Object { $_ -match "^[^#].*=" }
foreach ($line in $envContent) {
    $key, $value = $line.Split("=", 2)
    if ($key -and $value) {
        [Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim(), "Process")
    }
}

Write-Host "🔧 Configurações carregadas:" -ForegroundColor Cyan
Write-Host "   LOCAL_FORWARD_PORT: $env:LOCAL_FORWARD_PORT" -ForegroundColor White
Write-Host "   PUBLIC_EXPOSE_PORT: $env:PUBLIC_EXPOSE_PORT" -ForegroundColor White
Write-Host "   NGROK_AUTHTOKEN: $($env:NGROK_AUTHTOKEN.Substring(0, [Math]::Min(10, $env:NGROK_AUTHTOKEN.Length)))..." -ForegroundColor White

# Verifica se o token ngrok foi configurado
if ($env:NGROK_AUTHTOKEN -eq "seu_token_aqui") {
    Write-Host "❌ Configure o NGROK_AUTHTOKEN no arquivo .env!" -ForegroundColor Red
    exit 1
}

# Para containers existentes
Write-Host "🛑 Parando containers existentes..." -ForegroundColor Yellow
docker-compose down

# Build e start
Write-Host "🔨 Fazendo build dos containers..." -ForegroundColor Yellow
docker-compose build

Write-Host "🚀 Iniciando Albion.PortBridge..." -ForegroundColor Green
docker-compose up

Write-Host "✅ Albion.PortBridge iniciado com sucesso!" -ForegroundColor Green
Write-Host "🌐 Acesse http://localhost:4040 para ver o dashboard do ngrok" -ForegroundColor Cyan
