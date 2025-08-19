# 🔌 FRP Client - Albion.PortBridge

Este diretório contém os arquivos necessários para executar o **cliente FRP** na **máquina principal** onde roda o serviço Crypto/Sniffer.

## 📋 Pré-requisitos

- Windows 10/11 ou Linux
- Serviço Crypto escutando em `127.0.0.1:5050/UDP`
- Servidor FRP rodando no segundo PC
- Acesso à rede local

## 🗂️ Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `frpc.ini` | Configuração do cliente FRP |
| `frpc.example.ini` | Exemplo de configuração |
| `run-frpc.bat` | Script para executar o cliente |
| `install-frp.bat` | Script para baixar e instalar o FRP |

## ⚙️ Configuração

### 1. Instalar FRP

Execute o script de instalação:

```bash
install-frp.bat
```

### 2. Configurar IP do Servidor

Edite o arquivo `frpc.ini` e altere:

```ini
server_addr = IP_DO_SEGUNDO_PC
```

**Exemplo:**
```ini
server_addr = 192.168.18.31
```

### 3. Verificar Porta Local

Confirme que o serviço está escutando em:

```ini
local_ip = 127.0.0.1
local_port = 5050
```

## 🚀 Execução

### Iniciar Cliente

```bash
run-frpc.bat
```

### Verificar Status

O cliente FRP irá:
- Conectar ao servidor FRP
- Estabelecer o túnel UDP
- Redirecionar tráfego de `15151/UDP` → `127.0.0.1:5050/UDP`

## 🔄 Fluxo de Dados

```
[Cliente Remoto] → [192.168.18.31:15151/UDP] → [FRP Túnel] → [127.0.0.1:5050/UDP]
```

## 🧪 Teste de Conectividade

### Python
```bash
cd test
python test-udp.py
```

### PowerShell
```powershell
cd test
.\test-udp.ps1
```

### Netcat (Windows)
```bash
echo "ping" | nc -u 192.168.18.31 15151
```

## 📊 Monitoramento

### Logs
- **Cliente**: `frpc.log`
- **Servidor**: Verifique o dashboard do servidor FRP

### Status da Conexão
O cliente FRP mostra:
- Status da conexão com o servidor
- Túneis ativos
- Estatísticas de tráfego

## 🔧 Configurações Avançadas

### Criptografia e Compressão

```ini
use_encryption = true
use_compression = true
```

### Limite de Banda

```ini
bandwidth_limit = 1MB
meta_bandwidth_limit = 1MB
```

### Múltiplos Túneis

```ini
[albion-udp]
type = udp
local_ip = 127.0.0.1
local_port = 5050
remote_port = 15151

[outro-servico]
type = tcp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 8081
```

## 🚨 Troubleshooting

### Erro de Conexão

1. **Verifique o IP do servidor**
2. **Confirme que o frps está rodando**
3. **Verifique as regras de firewall**

### Túnel não funciona

1. **Confirme que o serviço local está rodando**
2. **Verifique a porta local (5050)**
3. **Teste com netcat localmente**

### Logs de erro

Verifique o arquivo `frpc.log` para detalhes dos erros.

## 🔄 Reinicialização Automática

Para reinicialização automática, crie um script:

```batch
:loop
frpc.exe -c frpc.ini
timeout /t 5
goto loop
```

## 📚 Recursos

- [Documentação oficial do FRP](https://gofrp.io/docs/)
- [GitHub do FRP](https://github.com/fatedier/frp)
- [Exemplos de configuração](https://github.com/fatedier/frp/tree/master/examples)
