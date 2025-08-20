# 🚀 Albion.PortBridge

[![.NET](https://img.shields.io/badge/.NET-8.0-blue.svg)](https://dotnet.microsoft.com/download/dotnet/8.0)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **TCP Proxy para exposição de serviços locais via Docker e ngrok**

O `Albion.PortBridge` é um microserviço criado para **expor uma porta TCP local da máquina (ex: `Crypto`, `Albion.Sniffer`) para o exterior** via `Docker` e `ngrok` ou proxy TCP personalizado.

## 🎯 Visão Geral

Este projeto é ideal para:
- ✅ **Testes de interceptação** de tráfego de rede
- ✅ **Simulação de rede** para desenvolvimento
- ✅ **Validação de bots remotos** 
- ✅ **Tunneling de tráfego** do cliente Albion Online
- ✅ **Debug remoto** de serviços locais
- ✅ **Engenharia reversa** com acesso externo

## 🧱 Arquitetura

```mermaid
graph LR
  Client[🔵 Cliente remoto]
  Ngrok[🌍 Túnel TCP (ngrok)]
  Proxy[🟩 Albion.PortBridge (TCP Proxy)]
  Crypto[🟡 Serviço Crypto em 127.0.0.1:5050]

  Client --> Ngrok
  Ngrok --> Proxy
  Proxy --> Crypto
```

### Componentes:

| Componente          | Função                                                                                                       |
| ------------------- | ------------------------------------------------------------------------------------------------------------ |
| `Albion.PortBridge` | Escuta uma porta TCP pública (ex: 0.0.0.0:5151) e redireciona para um endereço interno como `127.0.0.1:5050` |
| `Crypto`            | Serviço ou sniffer que escuta localmente em `localhost:5050`                                                 |
| `Ngrok`             | Tunelamento público da porta 5151 para internet                                                              |
| `Docker Compose`    | Orquestra os containers do Proxy e do Ngrok                                                                  |

## 🗂️ Estrutura do Projeto

```
Albion.PortBridge/
├── docker-compose.yml         # Orquestra proxy + ngrok
├── env.example                # Configurações de exemplo
├── Albion.Proxy/              # Código do TCP Proxy em .NET 8
│   ├── Program.cs             # Proxy TCP bidirecional
│   ├── Albion.Proxy.csproj   # Projeto .NET
│   └── Dockerfile             # Build do serviço .NET
├── ngrok/
│   └── ngrok.yml              # Configuração do túnel
├── scripts/                    # Scripts de inicialização
│   ├── start.ps1              # PowerShell (Windows)
│   └── start.sh               # Bash (Linux/Mac)
├── test/                      # Ferramentas de teste
│   ├── test-server.py         # Servidor de teste local
│   └── test-client.py         # Cliente de teste
└── README.md                  # Esta documentação
```

## ⚙️ Configuração Rápida

### 1. Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e rodando
- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) (para desenvolvimento local)
- [Python 3.7+](https://www.python.org/downloads/) (para testes)

### 2. Configuração

```bash
# Clone o projeto
git clone https://github.com/seu-user/Albion.PortBridge
cd Albion.PortBridge

# Copie e edite as configurações
cp env.example .env
# Edite o arquivo .env com suas configurações
```

**Arquivo `.env`:**
```env
LOCAL_FORWARD_PORT=5050      # Porta do serviço local (ex: Crypto)
PUBLIC_EXPOSE_PORT=5151      # Porta pública do proxy
NGROK_AUTHTOKEN=seu_token   # Token do ngrok (obrigatório!)
```

### 3. Obter Token do Ngrok

1. Acesse [ngrok.com](https://ngrok.com) e crie uma conta
2. Vá em [Dashboard > Auth](https://dashboard.ngrok.com/get-started/your-authtoken)
3. Copie seu authtoken
4. Cole no arquivo `.env`

## 🚀 Execução

### Opção 1: Scripts Automatizados

**Windows (PowerShell):**
```powershell
# Execute como Administrador se necessário
.\scripts\start.ps1
```

**Linux/Mac:**
```bash
chmod +x scripts/start.sh
./scripts/start.sh
```

### Opção 2: Docker Compose Manual

```bash
# Build e start
docker-compose up --build

# Em background
docker-compose up --build -d

# Parar
docker-compose down
```

### Opção 3: Desenvolvimento Local

```bash
# Terminal 1: Servidor de teste
cd test
python test-server.py

# Terminal 2: Proxy .NET
cd Albion.Proxy
dotnet run

# Terminal 3: Cliente de teste
cd test
python test-client.py
```

## 🧪 Testes

### 1. Servidor de Teste Local

```bash
cd test
python test-server.py
```

Este servidor simula o serviço `Crypto` em `127.0.0.1:5050` e responde a:
- `ping` → `pong`
- `crypto_request` → dados simulados
- Qualquer texto → echo da mensagem

### 2. Cliente de Teste

```bash
cd test
python test-client.py [host] [port]
```

**Exemplos:**
```bash
# Teste local
python test-client.py 127.0.0.1 5151

# Teste via ngrok (após obter URL pública)
python test-client.py x.tcp.ngrok.io 12345
```

### 3. Teste com Telnet

```bash
# Conecte diretamente ao proxy
telnet 127.0.0.1 5151

# Envie mensagens JSON
{"type": "ping"}
{"type": "crypto_request"}
```

## 📊 Monitoramento

### Dashboard do Ngrok
- **URL:** `http://localhost:4040`
- **Funcionalidades:** Inspeção de tráfego, logs, status dos túneis

### Logs do Proxy
```bash
# Ver logs em tempo real
docker-compose logs -f proxy

# Ver logs do ngrok
docker-compose logs -f ngrok
```

### Status dos Containers
```bash
docker-compose ps
docker-compose top
```

## 🔧 Configurações Avançadas

### Variáveis de Ambiente

| Variável | Padrão | Descrição |
|-----------|--------|-----------|
| `LOCAL_FORWARD_PORT` | `5050` | Porta do serviço local |
| `PUBLIC_EXPOSE_PORT` | `5151` | Porta pública do proxy |
| `NGROK_AUTHTOKEN` | - | Token de autenticação do ngrok |
| `LOG_LEVEL` | `INFO` | Nível de logging |
| `ENABLE_LOGGING` | `true` | Habilita/desabilita logs |

### Configuração do Ngrok

**Arquivo `ngrok/ngrok.yml`:**
```yaml
authtoken: ${NGROK_AUTHTOKEN}
tunnels:
  albion-sniffer:
    proto: tcp
    addr: proxy:${PUBLIC_EXPOSE_PORT}
    inspect: true
```

### Personalização do Proxy

O proxy pode ser customizado editando `Albion.Proxy/Program.cs`:
- Adicionar autenticação
- Implementar rate limiting
- Adicionar filtros de IP
- Implementar logging estruturado

## 🐛 Troubleshooting

### Problemas Comuns

**1. Erro de conexão recusada**
```bash
# Verifique se o serviço local está rodando
netstat -an | grep 5050
telnet 127.0.0.1 5050
```

**2. Ngrok não conecta**
```bash
# Verifique o token
docker-compose logs ngrok

# Teste o token manualmente
ngrok authtoken seu_token_aqui
```

**3. Proxy não inicia**
```bash
# Verifique as portas
netstat -an | grep 5151

# Verifique logs
docker-compose logs proxy
```

**4. Erro de permissão no Windows**
```powershell
# Execute PowerShell como Administrador
# Ou ajuste as permissões do Docker
```

### 🔴 **PROBLEMA CRÍTICO: Porta 5050 Ocupada**

**Sintoma:** O Albion.PortBridge não consegue iniciar na porta 5050, mostrando erro de "porta já em uso".

**Causa:** A porta 5050 está sendo ocupada por outro processo do Windows (geralmente `svchost.exe` com serviço `CDPSvc`).

**Solução Obrigatória:**

#### **Passo 1: Identificar o Processo Ocupante**
```powershell
# Verificar qual processo está usando a porta 5050
netstat -ano | findstr :5050

# Exemplo de saída:
# UDP    0.0.0.0:5050           *:*                                    10432
```

#### **Passo 2: Identificar o Serviço Específico**
```powershell
# Verificar qual serviço está rodando no PID identificado
tasklist /SVC /FI "PID eq 10432"

# Exemplo de saída:
# Nome da imagem    Identifi Serviços
# ========================= ======== ============================================
# svchost.exe          10432 CDPSvc
```

#### **Passo 3: Finalizar o Serviço Ocupante**
```powershell
# Opção 1: Parar o serviço (recomendado)
sc stop CDPSvc

# Opção 2: Desabilitar o serviço permanentemente
sc config CDPSvc start= disabled

# Opção 3: Forçar finalização do processo (último recurso)
taskkill /PID 10432 /F
```

#### **Passo 4: Verificar Liberação da Porta**
```powershell
# Confirmar que a porta foi liberada
netstat -ano | findstr :5050

# Se não retornar nada, a porta foi liberada com sucesso
```

#### **Scripts Automatizados**
Execute um dos scripts criados especificamente para este problema:

```bash
# Script Batch (execute como administrador)
stop-cdp-service.bat

# Script PowerShell (execute como administrador)
stop-cdp-service.ps1

# Script para forçar liberação da porta
force-release-port-5050.bat
```

#### **⚠️ IMPORTANTE:**
- **Execute sempre como administrador** para ter permissões suficientes
- O serviço `CDPSvc` pode reiniciar automaticamente - use `sc config CDPSvc start= disabled` para desabilitar permanentemente
- Se o problema persistir, pode ser necessário reiniciar o computador

### Logs de Debug

```bash
# Logs detalhados do proxy
docker-compose logs -f proxy

# Logs do ngrok
docker-compose logs -f ngrok

# Status dos containers
docker-compose ps
```

## 🚀 Casos de Uso

### 1. Teste de Bot Remoto
```bash
# 1. Inicie o Albion.PortBridge
./scripts/start.sh

# 2. Configure seu bot para conectar na URL do ngrok
# 3. O tráfego será redirecionado para seu serviço local
```

### 2. Debug de Serviço Local
```bash
# 1. Serviço local em 127.0.0.1:5050
# 2. Proxy redireciona 0.0.0.0:5151 → 127.0.0.1:5050
# 3. Ngrok expõe publicamente
# 4. Acesse de qualquer lugar
```

### 3. Interceptação de Tráfego
```bash
# 1. Configure seu sniffer em 127.0.0.1:5050
# 2. Inicie o proxy
# 3. Conecte clientes externos via ngrok
# 4. Analise o tráfego interceptado
```

## 🔮 Roadmap

- [ ] **Suporte a UDP** (`socat`, `frp`)
- [ ] **Empacotamento com binaries** do ngrok
- [ ] **Autenticação de origem** (firewall no proxy)
- [ ] **Dashboard Web** para configuração
- [ ] **Métricas e monitoramento** avançado
- [ ] **Suporte a múltiplos serviços** simultâneos
- [ ] **Templates de configuração** para casos comuns

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- [ngrok](https://ngrok.com) - Tunneling público
- [Docker](https://www.docker.com/) - Containerização
- [.NET](https://dotnet.microsoft.com/) - Runtime e framework

## 📞 Suporte

- **Issues:** [GitHub Issues](https://github.com/seu-user/Albion.PortBridge/issues)
- **Discussions:** [GitHub Discussions](https://github.com/seu-user/Albion.PortBridge/discussions)
- **Wiki:** [Documentação detalhada](https://github.com/seu-user/Albion.PortBridge/wiki)

---

**⭐ Se este projeto te ajudou, considere dar uma estrela!**
