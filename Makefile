# Makefile para Albion.PortBridge
# Uso: make [target]

.PHONY: help build start stop clean test dev logs status

# Variáveis
COMPOSE_FILE = docker-compose.yml
PROJECT_NAME = albion-portbridge

# Ajuda
help:
	@echo "🚀 Albion.PortBridge - Comandos disponíveis:"
	@echo ""
	@echo "📦 Build e Deploy:"
	@echo "  build     - Build dos containers"
	@echo "  start     - Inicia os serviços"
	@echo "  stop      - Para os serviços"
	@echo "  restart   - Reinicia os serviços"
	@echo "  clean     - Remove containers e imagens"
	@echo ""
	@echo "🔍 Monitoramento:"
	@echo "  logs      - Mostra logs em tempo real"
	@echo "  status    - Status dos containers"
	@echo "  top       - Processos dos containers"
	@echo ""
	@echo "🧪 Desenvolvimento:"
	@echo "  dev       - Modo desenvolvimento local"
	@echo "  test      - Executa testes"
	@echo ""
	@echo "📋 Utilitários:"
	@echo "  setup     - Configuração inicial"
	@echo "  update    - Atualiza dependências"

# Configuração inicial
setup:
	@echo "🔧 Configurando Albion.PortBridge..."
	@if [ ! -f .env ]; then \
		echo "📝 Copiando env.example para .env..."; \
		cp env.example .env; \
		echo "⚠️  IMPORTANTE: Edite o arquivo .env com suas configurações!"; \
		echo "   Especialmente o NGROK_AUTHTOKEN!"; \
	else \
		echo "✅ Arquivo .env já existe"; \
	fi
	@echo "🔍 Verificando Docker..."
	@docker --version || (echo "❌ Docker não está instalado!" && exit 1)
	@echo "✅ Configuração concluída!"

# Build dos containers
build:
	@echo "🔨 Fazendo build dos containers..."
	docker-compose -f $(COMPOSE_FILE) build

# Inicia os serviços
start: build
	@echo "🚀 Iniciando Albion.PortBridge..."
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "✅ Serviços iniciados!"
	@echo "🌐 Dashboard ngrok: http://localhost:4040"
	@echo "📊 Status: make status"

# Para os serviços
stop:
	@echo "🛑 Parando serviços..."
	docker-compose -f $(COMPOSE_FILE) down
	@echo "✅ Serviços parados!"

# Reinicia os serviços
restart: stop start

# Remove containers e imagens
clean:
	@echo "🧹 Limpando containers e imagens..."
	docker-compose -f $(COMPOSE_FILE) down --rmi all --volumes --remove-orphans
	docker system prune -f
	@echo "✅ Limpeza concluída!"

# Mostra logs em tempo real
logs:
	@echo "📋 Logs dos serviços (Ctrl+C para sair)..."
	docker-compose -f $(COMPOSE_FILE) logs -f

# Status dos containers
status:
	@echo "📊 Status dos containers:"
	docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "📈 Uso de recursos:"
	docker-compose -f $(COMPOSE_FILE) top

# Processos dos containers
top:
	docker-compose -f $(COMPOSE_FILE) top

# Modo desenvolvimento local
dev:
	@echo "🧪 Modo desenvolvimento local..."
	@echo "📋 Abra 3 terminais e execute:"
	@echo ""
	@echo "Terminal 1 (Servidor de teste):"
	@echo "  cd test && python test-server.py"
	@echo ""
	@echo "Terminal 2 (Proxy .NET):"
	@echo "  cd Albion.Proxy && dotnet run"
	@echo ""
	@echo "Terminal 3 (Cliente de teste):"
	@echo "  cd test && python test-client.py"
	@echo ""
	@echo "🔗 URLs de teste:"
	@echo "  Local: 127.0.0.1:5151"
	@echo "  Servidor: 127.0.0.1:5050"

# Executa testes
test:
	@echo "🧪 Executando testes..."
	@if command -v python3 >/dev/null 2>&1; then \
		echo "🐍 Testando servidor local..."; \
		cd test && python3 test-server.py & \
		SERVER_PID=$$!; \
		sleep 3; \
		echo "🔗 Testando cliente..."; \
		echo '{"type": "ping"}' | nc 127.0.0.1 5050; \
		kill $$SERVER_PID 2>/dev/null; \
		echo "✅ Testes concluídos!"; \
	else \
		echo "⚠️  Python não encontrado. Instale Python 3.7+ para executar os testes."; \
	fi

# Atualiza dependências
update:
	@echo "🔄 Atualizando dependências..."
	docker-compose -f $(COMPOSE_FILE) pull
	@echo "✅ Dependências atualizadas!"

# Comando padrão
.DEFAULT_GOAL := help
