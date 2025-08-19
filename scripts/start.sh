#!/bin/bash

# Script Bash para iniciar o Albion.PortBridge
# Execute com: chmod +x scripts/start.sh && ./scripts/start.sh

echo "🚀 Albion.PortBridge - Script de Inicialização"
echo "==============================================="

# Verifica se o Docker está rodando
echo "🔍 Verificando Docker..."
if ! docker version > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker primeiro."
    exit 1
fi
echo "✅ Docker está rodando"

# Verifica se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado. Copiando de env.example..."
    cp env.example .env
    echo "📝 Edite o arquivo .env com suas configurações antes de continuar."
    echo "   Especialmente o NGROK_AUTHTOKEN!"
    read -p "Pressione Enter para continuar..."
fi

# Carrega variáveis do .env
export $(cat .env | grep -v '^#' | xargs)

echo "🔧 Configurações carregadas:"
echo "   LOCAL_FORWARD_PORT: $LOCAL_FORWARD_PORT"
echo "   PUBLIC_EXPOSE_PORT: $PUBLIC_EXPOSE_PORT"
echo "   NGROK_AUTHTOKEN: ${NGROK_AUTHTOKEN:0:10}..."

# Verifica se o token ngrok foi configurado
if [ "$NGROK_AUTHTOKEN" = "seu_token_aqui" ]; then
    echo "❌ Configure o NGROK_AUTHTOKEN no arquivo .env!"
    exit 1
fi

# Para containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down

# Build e start
echo "🔨 Fazendo build dos containers..."
docker-compose build

echo "🚀 Iniciando Albion.PortBridge..."
docker-compose up

echo "✅ Albion.PortBridge iniciado com sucesso!"
echo "🌐 Acesse http://localhost:4040 para ver o dashboard do ngrok"
