using System.Net;
using System.Net.Sockets;
using Microsoft.Extensions.Configuration;

var config = new ConfigurationBuilder()
    .AddJsonFile("appsettings.json", optional: true)
    .AddCommandLine(args)
    .Build();

var localPort = int.Parse(config["LocalPort"] ?? "5050");
var destinationIp = config["TargetIp"] ?? "192.168.18.100";
var destinationPort = int.Parse(config["TargetPort"] ?? "5050");

Console.WriteLine($"🔁 Albion.UdpRepeater escutando UDP em 127.0.0.1:{localPort}");
Console.WriteLine($"📡 Reenviando pacotes para {destinationIp}:{destinationPort}");

using var listener = new UdpClient(localPort);

while (true)
{
    var result = await listener.ReceiveAsync();
    Console.WriteLine($"📦 {result.Buffer.Length} bytes recebidos de {result.RemoteEndPoint}");

    using var sender = new UdpClient();
    await sender.SendAsync(result.Buffer, result.Buffer.Length, destinationIp, destinationPort);
}