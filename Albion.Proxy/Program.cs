using System.Net;
using System.Net.Sockets;

namespace Albion.Proxy;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 Albion.PortBridge UDP - Iniciando...");
        
        var preferredPort = int.Parse(Environment.GetEnvironmentVariable("LOCAL_FORWARD_PORT") ?? "5050");
        var logLevel = Environment.GetEnvironmentVariable("LOG_LEVEL") ?? "INFO";
        var enableLogging = bool.Parse(Environment.GetEnvironmentVariable("ENABLE_LOGGING") ?? "true");

        Console.WriteLine($"🔧 Configuração:");
        Console.WriteLine($"   📡 Porta preferida: {preferredPort}");
        Console.WriteLine($"   📝 Logging: {(enableLogging ? "Ativado" : "Desativado")}");
        Console.WriteLine($"   📊 Nível de log: {logLevel}");

        // Tenta encontrar uma porta disponível
        var listenPort = await FindAvailablePortAsync(preferredPort, enableLogging);
        
        if (listenPort == -1)
        {
            Console.WriteLine("❌ Nenhuma porta disponível encontrada!");
            return;
        }

        var udpClient = new UdpClient(listenPort);
        udpClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);

        Console.WriteLine($"✅ Proxy UDP ativo! Escutando em 0.0.0.0:{listenPort}");
        Console.WriteLine($"🌐 Aguardando pacotes UDP...");
        
        if (listenPort != preferredPort)
        {
            Console.WriteLine($"⚠️  ATENÇÃO: Porta {preferredPort} estava ocupada, usando {listenPort}");
            Console.WriteLine($"💡 Atualize o FRP para redirecionar 15151 → 127.0.0.1:{listenPort}");
        }
        else
        {
            Console.WriteLine($"💡 Configure o FRP para redirecionar 15151 → 127.0.0.1:{listenPort}");
        }

        var packetCount = 0;

        while (true)
        {
            try
            {
                var result = await udpClient.ReceiveAsync();
                var packetId = Interlocked.Increment(ref packetCount);
                
                if (enableLogging)
                {
                    Console.WriteLine($"📦 Pacote #{packetId} recebido de {result.RemoteEndPoint} ({result.Buffer.Length} bytes)");
                }

                // Processa o pacote em background
                _ = Task.Run(async () => await ProcessPacketAsync(result.Buffer, result.RemoteEndPoint, packetId, enableLogging));
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Erro ao receber pacote: {ex.Message}");
            }
        }
    }

    static async Task<int> FindAvailablePortAsync(int preferredPort, bool enableLogging)
    {
        var portsToTry = new[] { preferredPort, 5051, 5052, 5053, 5054, 5055 };
        
        foreach (var port in portsToTry)
        {
            try
            {
                if (enableLogging)
                {
                    Console.WriteLine($"🔍 Tentando porta {port}...");
                }

                using var testClient = new UdpClient(port);
                testClient.Close();
                
                if (enableLogging)
                {
                    Console.WriteLine($"✅ Porta {port} disponível!");
                }
                
                return port;
            }
            catch (SocketException)
            {
                if (enableLogging)
                {
                    Console.WriteLine($"❌ Porta {port} ocupada, tentando próxima...");
                }
            }
        }
        
        return -1;
    }

    static async Task ProcessPacketAsync(byte[] data, IPEndPoint remoteEndPoint, int packetId, bool enableLogging)
    {
        try
        {
            if (enableLogging)
            {
                Console.WriteLine($"🔄 Processando pacote #{packetId} ({data.Length} bytes)");
                
                // Log dos primeiros bytes para debug
                var hexPreview = BitConverter.ToString(data.Take(Math.Min(16, data.Length)).ToArray());
                Console.WriteLine($"🔍 Preview: {hexPreview}");
            }

            // Aqui você pode adicionar lógica específica para processar os pacotes
            // Por exemplo, análise de protocolo, filtros, etc.
            
            if (enableLogging)
            {
                Console.WriteLine($"✅ Pacote #{packetId} processado com sucesso");
            }
        }
        catch (Exception ex)
        {
            if (enableLogging)
            {
                Console.WriteLine($"❌ Erro ao processar pacote #{packetId}: {ex.Message}");
            }
        }
    }
}
