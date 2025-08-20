# Servidor UDP simples para porta 5051
Write-Host "🚀 Iniciando servidor UDP na porta 5051..." -ForegroundColor Green
Write-Host "📡 Aguardando pacotes UDP..." -ForegroundColor Yellow
Write-Host "🛑 Pressione Ctrl+C para parar" -ForegroundColor Red

try {
    # Cria socket UDP
    $socket = New-Object System.Net.Sockets.UdpClient
    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 5051)
    $socket.Client.Bind($endpoint)
    
    Write-Host "✅ Servidor UDP iniciado em 0.0.0.0:5051" -ForegroundColor Green
    Write-Host "🔗 Teste via: .\test-udp-simple-5051.ps1" -ForegroundColor Cyan
    
    while ($true) {
        try {
            # Recebe dados
            $data = $socket.Receive([ref]$endpoint)
            $message = [System.Text.Encoding]::UTF8.GetString($data)
            $clientAddr = $endpoint.Address.ToString()
            $clientPort = $endpoint.Port
            
            Write-Host "📥 [$clientAddr`:$clientPort] Recebido: $message" -ForegroundColor Green
            
            # Processa mensagem e envia resposta
            $response = "Echo: $message"
            $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($response)
            $socket.Send($responseBytes, $responseBytes.Length, $endpoint)
            
            Write-Host "📤 [$clientAddr`:$clientPort] Enviado: $response" -ForegroundColor Blue
            
        } catch {
            Write-Host "❌ Erro ao processar mensagem: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ Erro ao iniciar servidor: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($socket) {
        $socket.Close()
        Write-Host "✅ Servidor UDP encerrado" -ForegroundColor Green
    }
}
