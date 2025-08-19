# Script PowerShell para executar Albion.PortBridge com .NET + ngrok
# Execute como Administrador se necessário

Write-Host "🚀 Albion.PortBridge - Modo .NET + ngrok" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Verifica se o .NET está instalado
Write-Host "🔍 Verificando .NET..." -ForegroundColor Yellow
try {
    dotnet --version | Out-Null
    Write-Host "✅ .NET está instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ .NET não está instalado. Instale o .NET 8.0 SDK primeiro." -ForegroundColor Red
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

# Verifica se o ngrok está instalado
Write-Host "🔍 Verificando ngrok..." -ForegroundColor Yellow
try {
    ngrok version | Out-Null
    Write-Host "✅ Ngrok está instalado" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Ngrok não está instalado. Instalando..." -ForegroundColor Yellow
    
    # Tenta instalar via Chocolatey
    try {
        choco install ngrok -y
        Write-Host "✅ Ngrok instalado via Chocolatey" -ForegroundColor Green
    } catch {
        Write-Host "❌ Não foi possível instalar o ngrok automaticamente." -ForegroundColor Red
        Write-Host "📥 Baixe manualmente em: https://ngrok.com/download" -ForegroundColor Yellow
        Write-Host "   Ou instale via: choco install ngrok" -ForegroundColor Yellow
        exit 1
    }
}

# Configura o token do ngrok
Write-Host "🔑 Configurando token do ngrok..." -ForegroundColor Yellow
ngrok authtoken $env:NGROK_AUTHTOKEN

Write-Host ""
Write-Host "🎯 Iniciando Albion.PortBridge em modo .NET + ngrok..." -ForegroundColor Green
Write-Host "📋 Abra 2 terminais e execute:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Terminal 1 (Proxy .NET):" -ForegroundColor White
Write-Host "  cd Albion.Proxy" -ForegroundColor Gray
Write-Host "  dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "Terminal 2 (Ngrok):" -ForegroundColor White
Write-Host "  ngrok tcp $env:PUBLIC_EXPOSE_PORT" -ForegroundColor Gray
Write-Host ""
Write-Host "🔗 URLs de acesso:" -ForegroundColor Cyan
Write-Host "  Local: 127.0.0.1:$env:PUBLIC_EXPOSE_PORT" -ForegroundColor White
Write-Host "  Servidor: 127.0.0.1:$env:LOCAL_FORWARD_PORT" -ForegroundColor White
Write-Host "  Público: URL do ngrok (será mostrada no terminal 2)" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Dashboard ngrok: http://localhost:4040" -ForegroundColor Cyan

# Pergunta se quer iniciar automaticamente
Write-Host ""
$choice = Read-Host "🚀 Deseja iniciar o proxy .NET agora? (s/n)"
if ($choice -eq "s" -or $choice -eq "S" -or $choice -eq "sim") {
    Write-Host "🚀 Iniciando proxy .NET..." -ForegroundColor Green
    Set-Location "Albion.Proxy"
    dotnet run
} else {
    Write-Host "📋 Execute os comandos manualmente nos terminais." -ForegroundColor Yellow
}

