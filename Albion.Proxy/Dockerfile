# Multi-stage build para otimização
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia arquivos do projeto
COPY ["Albion.Proxy.csproj", "./"]
RUN dotnet restore "Albion.Proxy.csproj"

# Copia código fonte
COPY . .
RUN dotnet build "Albion.Proxy.csproj" -c Release -o /app/build

# Publica a aplicação
FROM build AS publish
RUN dotnet publish "Albion.Proxy.csproj" -c Release -o /app/publish

# Runtime final
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Instala ferramentas úteis para debug
RUN apt-get update && apt-get install -y \
    curl \
    netcat \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Copia binários publicados
COPY --from=publish /app/publish .

# Expõe porta padrão
EXPOSE 5151

# Define usuário não-root para segurança
USER 1000

# Comando de inicialização
ENTRYPOINT ["dotnet", "Albion.Proxy.dll"]
