using System.Net;
using System.Net.Sockets;

namespace Albion.Proxy;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 Albion.PortBridge - Iniciando...");
        
        var listenPort = int.Parse(Environment.GetEnvironmentVariable("PUBLIC_EXPOSE_PORT") ?? "5151");
        var forwardPort = int.Parse(Environment.GetEnvironmentVariable("LOCAL_FORWARD_PORT") ?? "5050");
        var logLevel = Environment.GetEnvironmentVariable("LOG_LEVEL") ?? "INFO";
        var enableLogging = bool.Parse(Environment.GetEnvironmentVariable("ENABLE_LOGGING") ?? "true");

        Console.WriteLine($"🔧 Configuração:");
        Console.WriteLine($"   📡 Porta de escuta: {listenPort}");
        Console.WriteLine($"   🔄 Porta de destino: {forwardPort}");
        Console.WriteLine($"   📝 Logging: {(enableLogging ? "Ativado" : "Desativado")}");
        Console.WriteLine($"   📊 Nível de log: {logLevel}");

        var listener = new TcpListener(IPAddress.Any, listenPort);
        listener.Start();

        Console.WriteLine($"✅ Proxy ativo! Redirecionando 0.0.0.0:{listenPort} → 127.0.0.1:{forwardPort}");
        Console.WriteLine($"🌐 Aguardando conexões...");

        var connectionCount = 0;

        while (true)
        {
            try
            {
                var client = await listener.AcceptTcpClientAsync();
                var connectionId = Interlocked.Increment(ref connectionCount);
                
                if (enableLogging)
                {
                    Console.WriteLine($"🔗 Nova conexão #{connectionId} de {client.Client.RemoteEndPoint}");
                }

                _ = Task.Run(async () => await HandleClientAsync(client, forwardPort, connectionId, enableLogging));
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Erro ao aceitar conexão: {ex.Message}");
            }
        }
    }

    static async Task HandleClientAsync(TcpClient client, int forwardPort, int connectionId, bool enableLogging)
    {
        try
        {
            using var target = new TcpClient();
            
            // Conecta ao serviço local via host.docker.internal
            await target.ConnectAsync("host.docker.internal", forwardPort);
            
            if (enableLogging)
            {
                Console.WriteLine($"✅ Conexão #{connectionId} estabelecida com serviço local");
            }

            var clientStream = client.GetStream();
            var targetStream = target.GetStream();

            // Cria tasks para transferência bidirecional
            var clientToTarget = Task.Run(async () =>
            {
                try
                {
                    await clientStream.CopyToAsync(targetStream);
                    if (enableLogging)
                        Console.WriteLine($"📤 Conexão #{connectionId}: Cliente → Serviço finalizada");
                }
                catch (Exception ex)
                {
                    if (enableLogging)
                        Console.WriteLine($"❌ Erro na transferência Cliente→Serviço #{connectionId}: {ex.Message}");
                }
            });

            var targetToClient = Task.Run(async () =>
            {
                try
                {
                    await targetStream.CopyToAsync(clientStream);
                    if (enableLogging)
                        Console.WriteLine($"📥 Conexão #{connectionId}: Serviço → Cliente finalizada");
                }
                catch (Exception ex)
                {
                    if (enableLogging)
                        Console.WriteLine($"❌ Erro na transferência Serviço→Cliente #{connectionId}: {ex.Message}");
                }
            });

            // Aguarda uma das direções finalizar
            await Task.WhenAny(clientToTarget, targetToClient);
            
            if (enableLogging)
            {
                Console.WriteLine($"🔚 Conexão #{connectionId} finalizada");
            }
        }
        catch (Exception ex)
        {
            if (enableLogging)
            {
                Console.WriteLine($"❌ Erro na conexão #{connectionId}: {ex.Message}");
            }
        }
        finally
        {
            client.Close();
        }
    }
}
