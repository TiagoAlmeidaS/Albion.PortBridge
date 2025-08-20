# 📘 Albion.UdpRepeater

## 🎯 Objetivo

O **Albion.UdpRepeater** é uma aplicação leve em .NET 8 que funciona como um repetidor UDP, projetada para:

- **Escutar** pacotes UDP recebidos na porta 5050 localmente (onde o Crypto envia)
- **Reencaminhar** todos os pacotes para uma máquina remota da rede local (onde o Sniffer está escutando)
- **Configurar** facilmente o IP e porta de destino via arquivo ou argumentos de linha de comando

## 📦 Estrutura do Projeto

```
Albion.UdpRepeater/
├── Albion.UdpRepeater.csproj
├── Program.cs
├── appsettings.json
├── README.md
└── build-and-run.ps1
```

## ⚙️ Especificação Técnica

### 🔄 Comportamento

- **Escuta UDP** na porta 5050 (127.0.0.1)
- Para cada pacote recebido:
  - **Replica** o pacote para `IP_DE_DESTINO:PORTA_DESTINO` (ex: 192.168.18.100:5050)
- Funciona **continuamente** com log simples no console
- Exibe emojis para facilitar a visualização do fluxo de dados

## ▶️ Como Executar

### 🔧 Pré-requisitos

- **.NET 8 SDK** instalado
- **Porta 5050** liberada no firewall local
- Permissões de rede para escutar/enviar UDP

### 📦 Build

```bash
dotnet build -c Release
```

### 🚀 Execução

**Execução padrão** (usa configurações do appsettings.json):

```bash
dotnet run --project Albion.UdpRepeater
```

**Execução com override de destino**:

```bash
dotnet run --project Albion.UdpRepeater --TargetIp=192.168.18.105 --TargetPort=5050
```

### 🔧 Configuração

O arquivo `appsettings.json` contém as configurações padrão:

```json
{
  "LocalPort": 5050,
  "TargetIp": "192.168.18.100",
  "TargetPort": 5050
}
```

Você pode sobrescrever essas configurações via argumentos de linha de comando:

- `--LocalPort`: Porta local para escutar (padrão: 5050)
- `--TargetIp`: IP de destino para reencaminhar (padrão: 192.168.18.100)
- `--TargetPort`: Porta de destino (padrão: 5050)

## 🧪 Validação de Funcionamento

1. **No PC onde o Crypto roda**, execute o Albion.UdpRepeater
2. **Na máquina principal**, inicie o Sniffer escutando em 5050
3. Use **tcpdump**, **Wireshark** ou seu próprio sniffer para verificar os pacotes chegando

### Teste rápido com netcat

Em uma máquina de teste (destino):
```bash
nc -ul 5050
```

Na máquina local (com o repeater rodando):
```bash
echo "teste" | nc -u 127.0.0.1 5050
```

## 🛡️ Regras de Firewall

### Windows (PowerShell como Admin)

```powershell
New-NetFirewallRule -DisplayName "Albion Udp Repeater IN" -Direction Inbound -Protocol UDP -LocalPort 5050 -Action Allow
```

### Linux (iptables)

```bash
sudo iptables -A INPUT -p udp --dport 5050 -j ACCEPT
```

## 🔄 Alternativa com socat

Se preferir não usar C#, você pode usar o `socat`:

```bash
socat -v UDP-LISTEN:5050,fork UDP:192.168.18.100:5050
```

## 📊 Logs e Monitoramento

O aplicativo exibe logs no console com emojis para facilitar o acompanhamento:

- 🔁 Inicialização do repeater
- 📡 Configuração de destino
- 📦 Pacotes recebidos e reenviados

## 🚨 Troubleshooting

### Erro: "Permission denied"
- Execute com privilégios administrativos se necessário
- Verifique se a porta não está em uso: `netstat -an | grep 5050`

### Pacotes não chegam ao destino
- Verifique o firewall em ambas as máquinas
- Confirme que o IP de destino está correto e acessível: `ping 192.168.18.100`
- Use Wireshark para rastrear os pacotes

### Alta latência
- Considere usar uma thread separada para envio
- Verifique a qualidade da conexão de rede

## 📝 Notas de Desenvolvimento

- Usa `UdpClient` assíncrono para melhor performance
- Configuração flexível via JSON e argumentos de linha de comando
- Design simples e focado em confiabilidade
- Logs informativos para debug e monitoramento

## 📄 Licença

Este projeto faz parte do ecossistema Albion para análise de tráfego de rede.