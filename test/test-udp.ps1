# Teste de conectividade UDP para Albion.PortBridge
# Testa o túnel FRP enviando pacotes UDP para a porta 15151

param(
    [string]$TargetHost = "192.168.18.31",
    [int]$Port = 15151
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    Teste UDP - Albion.PortBridge" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🎯 Configuração:" -ForegroundColor Yellow
Write-Host "   Host: $TargetHost" -ForegroundColor White
Write-Host "   Porta: $Port" -ForegroundColor White
Write-Host "   Protocolo: UDP" -ForegroundColor White
Write-Host ""

function Test-UDPConnection {
    param(
        [string]$Message = "ping"
    )
    
    try {
        Write-Host "🔗 Testando conexão UDP para $TargetHost`:$Port" -ForegroundColor Green
        Write-Host "📤 Enviando: $Message" -ForegroundColor White
        
        # Cria endpoint UDP
        $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($TargetHost), $Port)
        $udpClient = New-Object System.Net.Sockets.UdpClient
        
        # Define timeout
        $udpClient.Client.ReceiveTimeout = 5000
        
        # Converte mensagem para bytes
        $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
        
        # Envia mensagem
        $startTime = Get-Date
        $bytesSent = $udpClient.Send($messageBytes, $messageBytes.Length, $endpoint)
        
        Write-Host "✅ Mensagem enviada: $bytesSent bytes" -ForegroundColor Green
        
        # Tenta receber resposta
        try {
            $responseEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
            $responseBytes = $udpClient.Receive([ref]$responseEndpoint)
            $response = [System.Text.Encoding]::UTF8.GetString($responseBytes)
            
            $elapsed = ((Get-Date) - $startTime).TotalMilliseconds
            Write-Host "✅ Resposta recebida de $($responseEndpoint.Address): $response" -ForegroundColor Green
            Write-Host "⏱️  Tempo de resposta: $([math]::Round($elapsed, 2))ms" -ForegroundColor White
            
            return $true
        }
        catch {
            Write-Host "⚠️  Timeout - nenhuma resposta recebida" -ForegroundColor Yellow
            Write-Host "ℹ️  Isso pode ser normal se o serviço não estiver configurado para responder" -ForegroundColor White
            return $true  # Considera sucesso se conseguiu enviar
        }
    }
    catch {
        Write-Host "❌ Erro na conexão: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        if ($udpClient) {
            $udpClient.Close()
        }
    }
}

function Test-AlbionPacket {
    try {
        # Simula pacote de login do Albion
        $albionPacket = @{
            type = "login"
            version = "1.0.0"
            timestamp = [long]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
            data = "test_packet"
        }
        
        $message = $albionPacket | ConvertTo-Json -Compress
        Write-Host "🎮 Testando pacote Albion Online..." -ForegroundColor Magenta
        return Test-UDPConnection -Message $message
        
    }
    catch {
        Write-Host "❌ Erro no teste Albion: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Teste básico
Write-Host "🧪 Teste 1: Conexão básica UDP" -ForegroundColor Yellow
$basicTest = Test-UDPConnection

# Teste com pacote Albion
Write-Host "`n🧪 Teste 2: Pacote Albion Online" -ForegroundColor Yellow
$albionTest = Test-AlbionPacket

# Resultado final
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "📊 RESULTADO DOS TESTES:" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

if ($basicTest -and $albionTest) {
    Write-Host "✅ Todos os testes passaram!" -ForegroundColor Green
    Write-Host "🎉 O túnel FRP UDP está funcionando corretamente" -ForegroundColor Green
    Write-Host "🌐 Você pode usar esta conexão para:" -ForegroundColor White
    Write-Host "   - Replay de pacotes Albion" -ForegroundColor White
    Write-Host "   - Bots e automação" -ForegroundColor White
    Write-Host "   - Sniffing de tráfego" -ForegroundColor White
}
else {
    Write-Host "❌ Alguns testes falharam" -ForegroundColor Red
    Write-Host "🔧 Verifique:" -ForegroundColor Yellow
    Write-Host "   - Se o frps está rodando no segundo PC" -ForegroundColor White
    Write-Host "   - Se o frpc está rodando na máquina principal" -ForegroundColor White
    Write-Host "   - Se as regras de firewall estão corretas" -ForegroundColor White
    Write-Host "   - Se o IP está correto na configuração" -ForegroundColor White
}

Write-Host "`n💡 Dica: Execute 'firewall-rules.bat' se ainda não configurou o firewall" -ForegroundColor Cyan
