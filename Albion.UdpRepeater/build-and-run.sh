#!/bin/bash

# Albion.UdpRepeater - Build and Run Script (Linux/Mac)
# Este script automatiza o build e execução do UDP Repeater

# Valores padrão
TARGET_IP="192.168.18.100"
TARGET_PORT="5050"
LOCAL_PORT="5050"
BUILD_ONLY=false
RELEASE=false

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --target-ip)
            TARGET_IP="$2"
            shift 2
            ;;
        --target-port)
            TARGET_PORT="$2"
            shift 2
            ;;
        --local-port)
            LOCAL_PORT="$2"
            shift 2
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --release)
            RELEASE=true
            shift
            ;;
        --help)
            echo "Uso: $0 [opções]"
            echo ""
            echo "Opções:"
            echo "  --target-ip IP      IP de destino (padrão: 192.168.18.100)"
            echo "  --target-port PORT  Porta de destino (padrão: 5050)"
            echo "  --local-port PORT   Porta local (padrão: 5050)"
            echo "  --build-only        Apenas compila, não executa"
            echo "  --release           Compila em modo Release"
            echo "  --help              Mostra esta ajuda"
            exit 0
            ;;
        *)
            echo "Opção desconhecida: $1"
            echo "Use --help para ver as opções disponíveis"
            exit 1
            ;;
    esac
done

# Define o modo de build
if [ "$RELEASE" = true ]; then
    CONFIGURATION="Release"
else
    CONFIGURATION="Debug"
fi

echo -e "${CYAN}========================================"
echo -e "     Albion.UdpRepeater Build & Run     "
echo -e "========================================${NC}"
echo ""

# Verifica se dotnet está instalado
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}❌ .NET SDK não encontrado!${NC}"
    echo -e "${YELLOW}Por favor, instale o .NET 8 SDK:${NC}"
    echo "  https://dotnet.microsoft.com/download/dotnet/8.0"
    exit 1
fi

# Limpa builds anteriores
echo -e "${YELLOW}🧹 Limpando builds anteriores...${NC}"
dotnet clean -c $CONFIGURATION 2>&1 > /dev/null

# Restaura dependências
echo -e "${YELLOW}📦 Restaurando dependências...${NC}"
dotnet restore

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao restaurar dependências!${NC}"
    exit 1
fi

# Compila o projeto
echo -e "${YELLOW}🔨 Compilando em modo $CONFIGURATION...${NC}"
dotnet build -c $CONFIGURATION

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro na compilação!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build concluído com sucesso!${NC}"
echo ""

# Se for apenas build, para aqui
if [ "$BUILD_ONLY" = true ]; then
    echo -e "${CYAN}📁 Binários disponíveis em: bin/$CONFIGURATION/net8.0/${NC}"
    exit 0
fi

# Executa o aplicativo
echo -e "${CYAN}========================================"
echo -e "         Iniciando UDP Repeater         "
echo -e "========================================${NC}"
echo ""
echo -e "${YELLOW}Configuração:${NC}"
echo -e "${WHITE}  📥 Porta Local: $LOCAL_PORT${NC}"
echo -e "${WHITE}  📤 Destino: ${TARGET_IP}:${TARGET_PORT}${NC}"
echo ""
echo -e "${WHITE}Pressione Ctrl+C para parar${NC}"
echo -e "----------------------------------------"
echo ""

# Executa com os parâmetros fornecidos
dotnet run --project . --configuration $CONFIGURATION -- \
    --LocalPort $LOCAL_PORT \
    --TargetIp $TARGET_IP \
    --TargetPort $TARGET_PORT