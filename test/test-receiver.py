#!/usr/bin/env python3
"""
Teste da máquina receptora - Albion.PortBridge
Testa se sua máquina está recebendo dados UDP na porta 15151
"""

import socket
import time
import json
import threading

def start_udp_server(host="0.0.0.0", port=15151):
    """Inicia servidor UDP para receber dados"""
    try:
        # Cria socket UDP
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind((host, port))
        
        print(f"🚀 Servidor UDP iniciado em {host}:{port}")
        print(f"📡 Aguardando dados do túnel FRP...")
        print(f"💡 Execute o teste de envio em outra máquina")
        print()
        
        # Contador de pacotes
        packet_count = 0
        
        while True:
            try:
                # Recebe dados
                data, addr = sock.recvfrom(4096)
                packet_count += 1
                
                # Timestamp
                timestamp = time.strftime("%H:%M:%S")
                
                print(f"📦 Pacote #{packet_count} recebido às {timestamp}")
                print(f"   📍 Origem: {addr}")
                print(f"   📏 Tamanho: {len(data)} bytes")
                
                # Tenta decodificar como JSON
                try:
                    json_data = json.loads(data.decode('utf-8'))
                    print(f"   📋 Conteúdo JSON: {json.dumps(json_data, indent=2)}")
                except:
                    # Se não for JSON, mostra como texto
                    try:
                        text_data = data.decode('utf-8')
                        print(f"   📝 Conteúdo: {text_data}")
                    except:
                        # Se não for texto, mostra como hex
                        print(f"   🔢 Conteúdo Hex: {data.hex()}")
                
                print()
                
            except KeyboardInterrupt:
                print("\n🛑 Servidor interrompido pelo usuário")
                break
            except Exception as e:
                print(f"❌ Erro ao receber dados: {e}")
                break
        
        sock.close()
        
    except Exception as e:
        print(f"❌ Erro ao iniciar servidor: {e}")

def test_local_udp():
    """Testa se a porta UDP está disponível localmente"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind(("127.0.0.1", 15151))
        sock.close()
        print("✅ Porta 15151/UDP disponível localmente")
        return True
    except Exception as e:
        print(f"❌ Porta 15151/UDP não disponível: {e}")
        return False

def main():
    """Função principal"""
    print("=" * 60)
    print("    Teste da Máquina Receptora - Albion.PortBridge")
    print("=" * 60)
    print()
    
    print("🎯 Este teste verifica se SUA MÁQUINA está configurada")
    print("   para receber dados UDP do PC que roda o Crypto.")
    print()
    
    # Testa se a porta está disponível
    print("🧪 Teste 1: Disponibilidade da porta UDP")
    if not test_local_udp():
        print("❌ Configure o firewall primeiro: firewall-rules.bat")
        return
    
    print()
    print("🧪 Teste 2: Servidor UDP receptivo")
    print("📋 Para testar completamente:")
    print("   1. Mantenha este script rodando")
    print("   2. Execute o teste de envio no PC do Crypto")
    print("   3. Verifique se os dados chegam aqui")
    print()
    
    # Inicia o servidor
    try:
        start_udp_server()
    except KeyboardInterrupt:
        print("\n👋 Teste finalizado")

if __name__ == "__main__":
    main()
