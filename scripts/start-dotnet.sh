#!/bin/bash

# Script Bash para executar Albion.PortBridge com .NET + ngrok
# Execute com: chmod +x scripts/start-dotnet.sh && ./scripts/start-dotnet.sh

echo "🚀 Albion.PortBridge - Modo .NET + ngrok"
echo "========================================="

# Verifica se o .NET está instalado
echo "🔍 Verificando .NET..."
if ! dotnet --version > /dev/null 2>&1; then
    echo "❌ .NET não está instalado. Instale o .NET 8.0 SDK primeiro."
    exit 1
fi
echo "✅ .NET está instalado"

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

# Verifica se o ngrok está instalado
echo "🔍 Verificando ngrok..."
if ! ngrok version > /dev/null 2>&1; then
    echo "⚠️  Ngrok não está instalado. Instalando..."
    
    # Detecta o sistema operacional
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v snap > /dev/null 2>&1; then
            sudo snap install ngrok
        elif command -v apt-get > /dev/null 2>&1; then
            curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
            echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
            sudo apt update && sudo apt install ngrok
        else
            echo "❌ Não foi possível instalar o ngrok automaticamente."
            echo "📥 Baixe manualmente em: https://ngrok.com/download"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew > /dev/null 2>&1; then
            brew install ngrok
        else
            echo "❌ Homebrew não está instalado. Instale primeiro:"
            echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    else
        echo "❌ Sistema operacional não suportado para instalação automática."
        echo "📥 Baixe manualmente em: https://ngrok.com/download"
        exit 1
    fi
fi
echo "✅ Ngrok está instalado"

# Configura o token do ngrok
echo "🔑 Configurando token do ngrok..."
ngrok authtoken $NGROK_AUTHTOKEN

echo ""
echo "🎯 Iniciando Albion.PortBridge em modo .NET + ngrok..."
echo "📋 Abra 2 terminais e execute:"
echo ""
echo "Terminal 1 (Proxy .NET):"
echo "  cd Albion.Proxy"
echo "  dotnet run"
echo ""
echo "Terminal 2 (Ngrok):"
echo "  ngrok tcp $PUBLIC_EXPOSE_PORT"
echo ""
echo "🔗 URLs de acesso:"
echo "  Local: 127.0.0.1:$PUBLIC_EXPOSE_PORT"
echo "  Servidor: 127.0.0.1:$LOCAL_FORWARD_PORT"
echo "  Público: URL do ngrok (será mostrada no terminal 2)"
echo ""
echo "🌐 Dashboard ngrok: http://localhost:4040"

# Pergunta se quer iniciar automaticamente
echo ""
read -p "🚀 Deseja iniciar o proxy .NET agora? (s/n): " choice
if [[ "$choice" =~ ^[Ss]$ ]] || [[ "$choice" =~ ^[Ss]im$ ]]; then
    echo "🚀 Iniciando proxy .NET..."
    cd Albion.Proxy
    dotnet run
else
    echo "📋 Execute os comandos manualmente nos terminais."
fi

