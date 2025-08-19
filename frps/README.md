# 🚀 FRP Server - Albion.PortBridge

Este diretório contém os arquivos necessários para executar o **servidor FRP** no **segundo PC** da sua rede local.

## 📋 Pré-requisitos

- Windows 10/11 ou Linux
- Acesso à rede local
- Porta 6000/UDP disponível
- Porta 7500/TCP disponível (para dashboard)

## 🗂️ Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `frps.ini` | Configuração do servidor FRP |
| `frps.example.ini` | Exemplo de configuração |
| `run-frps.bat` | Script para executar o servidor |
| `install-frp.bat` | Script para baixar e instalar o FRP |

## ⚙️ Configuração

### 1. Instalar FRP

Execute o script de instalação:

```bash
install-frp.bat
```

Isso irá:
- Baixar o FRP da versão mais recente
- Extrair os executáveis
- Copiar `frps.exe` e `frpc.exe` para esta pasta

### 2. Configurar IP

Edite o arquivo `frpc.ini` na pasta `frpc/` e altere:

```ini
server_addr = SEU_IP_AQUI
```

### 3. Configurar Firewall

Execute o script de firewall na pasta raiz:

```bash
firewall-rules.bat
```

## 🚀 Execução

### Iniciar Servidor

```bash
run-frps.bat
```

### Verificar Status

Acesse o dashboard: http://localhost:7500
- Usuário: `admin`
- Senha: `admin123`

## 📊 Monitoramento

O servidor FRP fornece:

- **Dashboard Web**: http://localhost:7500
- **Logs**: `frps.log`
- **Métricas**: Conexões ativas, túneis, etc.

## 🔧 Configurações Avançadas

### Criptografia

Para habilitar criptografia, descomente em `frps.ini`:

```ini
use_encryption = true
use_compression = true
```

### Logs Detalhados

```ini
log_level = debug
log_max_days = 7
```

### Múltiplos Túneis

Para adicionar mais túneis, adicione seções no `frpc.ini`:

```ini
[outro-tunel]
type = udp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 8081
```

## 🚨 Troubleshooting

### Porta já em uso

```bash
netstat -an | findstr :6000
```

### Firewall bloqueando

Execute novamente:
```bash
firewall-rules.bat
```

### Logs de erro

Verifique o arquivo `frps.log` para detalhes dos erros.

## 📚 Recursos

- [Documentação oficial do FRP](https://gofrp.io/docs/)
- [GitHub do FRP](https://github.com/fatedier/frp)
- [Exemplos de configuração](https://github.com/fatedier/frp/tree/master/examples)
