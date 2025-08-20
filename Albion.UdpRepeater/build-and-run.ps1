# Albion.UdpRepeater - Build and Run Script
# Este script automatiza o build e execução do UDP Repeater

param(
    [string]$TargetIp = "192.168.18.100",
    [string]$TargetPort = "5050",
    [string]$LocalPort = "5050",
    [switch]$BuildOnly,
    [switch]$Release
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     Albion.UdpRepeater Build & Run     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define o modo de build
$Configuration = if ($Release) { "Release" } else { "Debug" }

# Limpa builds anteriores
Write-Host "🧹 Limpando builds anteriores..." -ForegroundColor Yellow
dotnet clean -c $Configuration 2>&1 | Out-Null

# Restaura dependências
Write-Host "📦 Restaurando dependências..." -ForegroundColor Yellow
dotnet restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao restaurar dependências!" -ForegroundColor Red
    exit 1
}

# Compila o projeto
Write-Host "🔨 Compilando em modo $Configuration..." -ForegroundColor Yellow
dotnet build -c $Configuration

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro na compilação!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build concluído com sucesso!" -ForegroundColor Green
Write-Host ""

# Se for apenas build, para aqui
if ($BuildOnly) {
    Write-Host "📁 Binários disponíveis em: bin/$Configuration/net8.0/" -ForegroundColor Cyan
    exit 0
}

# Executa o aplicativo
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         Iniciando UDP Repeater         " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuração:" -ForegroundColor Yellow
Write-Host "  📥 Porta Local: $LocalPort" -ForegroundColor White
Write-Host "  📤 Destino: ${TargetIp}:${TargetPort}" -ForegroundColor White
Write-Host ""
Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Gray
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Executa com os parâmetros fornecidos
dotnet run --project . --configuration $Configuration -- `
    --LocalPort $LocalPort `
    --TargetIp $TargetIp `
    --TargetPort $TargetPort