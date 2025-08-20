# Teste simples de UDP para porta 5050
Write-Host "🧪 Testando conectividade UDP com porta 5050..." -ForegroundColor Yellow

try {
    # Cria socket UDP
    $socket = New-Object System.Net.Sockets.UdpClient
    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse('127.0.0.1'), 5050)
    
    # Dados de teste
    $testData = '{"type":"ping","test":"udp"}'
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($testData)
    
    Write-Host "📤 Enviando dados para 127.0.0.1:5050..." -ForegroundColor Green
    Write-Host "📝 Dados: $testData" -ForegroundColor Cyan
    
    # Envia dados
    $bytesSent = $socket.Send($bytes, $bytes.Length, $endpoint)
    
    Write-Host "✅ $bytesSent bytes enviados com sucesso!" -ForegroundColor Green
    
    # Tenta receber resposta (opcional)
    Write-Host "📥 Aguardando resposta..." -ForegroundColor Yellow
    $socket.Client.ReceiveTimeout = 3000  # 3 segundos
    
    try {
        $responseBytes = $socket.Receive([ref]$endpoint)
        $response = [System.Text.Encoding]::UTF8.GetString($responseBytes)
        Write-Host "📤 Resposta recebida: $response" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Nenhuma resposta recebida (timeout)" -ForegroundColor Yellow
        Write-Host "ℹ️  Isso pode ser normal se o servidor não estiver configurado para responder" -ForegroundColor Cyan
    }
    
    $socket.Close()
    Write-Host "✅ Teste concluído com sucesso!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro no teste: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🔧 Verifique se o servidor UDP está rodando na porta 5050" -ForegroundColor Yellow
}
