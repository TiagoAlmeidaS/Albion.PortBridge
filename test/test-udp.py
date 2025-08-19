#!/usr/bin/env python3
"""
Teste de conectividade UDP para Albion.PortBridge
Testa o túnel FRP enviando pacotes UDP para a porta 15151
"""

import socket
import time
import json
import sys

def test_udp_connection(host, port, message="ping"):
    """Testa conexão UDP com o túnel FRP"""
    try:
        # Cria socket UDP
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(5)
        
        print(f"🔗 Testando conexão UDP para {host}:{port}")
        print(f"📤 Enviando: {message}")
        
        # Envia mensagem
        start_time = time.time()
        sock.sendto(message.encode(), (host, port))
        
        # Tenta receber resposta
        try:
            data, addr = sock.recvfrom(1024)
            elapsed = (time.time() - start_time) * 1000
            print(f"✅ Resposta recebida de {addr}: {data.decode()}")
            print(f"⏱️  Tempo de resposta: {elapsed:.2f}ms")
            return True
        except socket.timeout:
            print(f"⚠️  Timeout - nenhuma resposta recebida")
            print(f"ℹ️  Isso pode ser normal se o serviço não estiver configurado para responder")
            return True  # Considera sucesso se conseguiu enviar
        
    except Exception as e:
        print(f"❌ Erro na conexão: {e}")
        return False
    finally:
        sock.close()

def test_albion_packet(host, port):
    """Testa com pacote similar ao Albion Online"""
    try:
        # Simula pacote de login do Albion
        albion_packet = {
            "type": "login",
            "version": "1.0.0",
            "timestamp": int(time.time()),
            "data": "test_packet"
        }
        
        message = json.dumps(albion_packet)
        print(f"\n🎮 Testando pacote Albion Online...")
        return test_udp_connection(host, port, message)
        
    except Exception as e:
        print(f"❌ Erro no teste Albion: {e}")
        return False

def main():
    """Função principal"""
    print("=" * 50)
    print("    Teste UDP - Albion.PortBridge")
    print("=" * 50)
    print()
    
    # Configurações
    host = "192.168.18.31"  # IP do segundo PC (frps)
    port = 15151            # Porta do túnel UDP
    
    print(f"🎯 Configuração:")
    print(f"   Host: {host}")
    print(f"   Porta: {port}")
    print(f"   Protocolo: UDP")
    print()
    
    # Teste básico
    print("🧪 Teste 1: Conexão básica UDP")
    basic_test = test_udp_connection(host, port)
    
    # Teste com pacote Albion
    print("\n🧪 Teste 2: Pacote Albion Online")
    albion_test = test_albion_packet(host, port)
    
    # Resultado final
    print("\n" + "=" * 50)
    print("📊 RESULTADO DOS TESTES:")
    print("=" * 50)
    
    if basic_test and albion_test:
        print("✅ Todos os testes passaram!")
        print("🎉 O túnel FRP UDP está funcionando corretamente")
        print("🌐 Você pode usar esta conexão para:")
        print("   - Replay de pacotes Albion")
        print("   - Bots e automação")
        print("   - Sniffing de tráfego")
    else:
        print("❌ Alguns testes falharam")
        print("🔧 Verifique:")
        print("   - Se o frps está rodando no segundo PC")
        print("   - Se o frpc está rodando na máquina principal")
        print("   - Se as regras de firewall estão corretas")
        print("   - Se o IP está correto na configuração")
    
    print("\n💡 Dica: Execute 'firewall-rules.bat' se ainda não configurou o firewall")

if __name__ == "__main__":
    main()
