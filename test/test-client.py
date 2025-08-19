#!/usr/bin/env python3
"""
Cliente de teste para testar a conexão via Albion.PortBridge
Execute: python test/test-client.py [host] [port]
"""

import socket
import json
import time
import sys
import threading
from datetime import datetime

class TestClient:
    def __init__(self, host='127.0.0.1', port=5151):
        self.host = host
        self.port = port
        self.socket = None
        self.connected = False
        self.received_messages = []
        
    def connect(self):
        """Conecta ao servidor"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.settimeout(10)
            self.socket.connect((self.host, self.port))
            self.connected = True
            
            print(f"✅ Conectado ao {self.host}:{self.port}")
            
            # Thread para receber mensagens
            receive_thread = threading.Thread(target=self.receive_messages)
            receive_thread.daemon = True
            receive_thread.start()
            
            return True
            
        except Exception as e:
            print(f"❌ Erro ao conectar: {e}")
            return False
    
    def disconnect(self):
        """Desconecta do servidor"""
        self.connected = False
        if self.socket:
            try:
                self.socket.close()
            except:
                pass
        print("🔚 Desconectado")
    
    def send_message(self, message):
        """Envia mensagem para o servidor"""
        if not self.connected:
            print("❌ Não conectado")
            return False
        
        try:
            if isinstance(message, dict):
                message = json.dumps(message)
            
            self.socket.send((message + "\n").encode())
            print(f"📤 Enviado: {message}")
            return True
            
        except Exception as e:
            print(f"❌ Erro ao enviar mensagem: {e}")
            return False
    
    def receive_messages(self):
        """Recebe mensagens do servidor"""
        while self.connected:
            try:
                data = self.socket.recv(1024)
                if not data:
                    break
                
                message = data.decode().strip()
                self.received_messages.append({
                    'timestamp': datetime.now().isoformat(),
                    'message': message
                })
                
                print(f"📥 Recebido: {message}")
                
            except socket.timeout:
                continue
            except Exception as e:
                if self.connected:
                    print(f"❌ Erro ao receber mensagem: {e}")
                break
        
        self.connected = False
    
    def run_interactive(self):
        """Executa modo interativo"""
        print(f"🔧 Modo interativo ativo. Comandos disponíveis:")
        print(f"   ping - Envia ping")
        print(f"   crypto - Solicita dados criptografados")
        print(f"   echo <texto> - Envia texto para echo")
        print(f"   status - Mostra status da conexão")
        print(f"   quit - Sair")
        print()
        
        while self.connected:
            try:
                command = input("> ").strip()
                
                if command == "quit":
                    break
                elif command == "ping":
                    self.send_message({"type": "ping"})
                elif command == "crypto":
                    self.send_message({"type": "crypto_request"})
                elif command == "status":
                    print(f"📊 Status: Conectado = {self.connected}")
                    print(f"📥 Mensagens recebidas: {len(self.received_messages)}")
                elif command.startswith("echo "):
                    text = command[5:]
                    self.send_message({"type": "echo", "text": text})
                elif command:
                    # Envia comando como texto simples
                    self.send_message(command)
                    
            except KeyboardInterrupt:
                break
            except EOFError:
                break
    
    def run_automated_test(self):
        """Executa teste automatizado"""
        print("🧪 Executando teste automatizado...")
        
        test_messages = [
            {"type": "ping"},
            {"type": "crypto_request"},
            {"type": "echo", "text": "Teste automatizado"},
            "Hello World!",
            {"type": "custom", "data": "Dados de teste"}
        ]
        
        for i, msg in enumerate(test_messages, 1):
            print(f"\n📝 Teste {i}/{len(test_messages)}")
            self.send_message(msg)
            time.sleep(1)  # Aguarda resposta
        
        print(f"\n✅ Teste automatizado concluído!")
        print(f"📥 Total de mensagens recebidas: {len(self.received_messages)}")
        
        # Mostra últimas mensagens
        if self.received_messages:
            print(f"\n📋 Últimas mensagens recebidas:")
            for msg in self.received_messages[-5:]:
                print(f"   [{msg['timestamp']}] {msg['message']}")

def main():
    # Parse argumentos
    host = '127.0.0.1'
    port = 5151
    
    if len(sys.argv) > 1:
        host = sys.argv[1]
    if len(sys.argv) > 2:
        port = int(sys.argv[2])
    
    print(f"🚀 Cliente de teste para Albion.PortBridge")
    print(f"🔗 Conectando em {host}:{port}")
    print()
    
    client = TestClient(host, port)
    
    try:
        if client.connect():
            # Aguarda um pouco para receber mensagem de boas-vindas
            time.sleep(1)
            
            # Pergunta o modo de operação
            print("\n🎯 Escolha o modo de operação:")
            print("1. Interativo (comandos manuais)")
            print("2. Automatizado (teste rápido)")
            
            try:
                choice = input("Escolha (1 ou 2): ").strip()
                
                if choice == "2":
                    client.run_automated_test()
                else:
                    client.run_interactive()
                    
            except (KeyboardInterrupt, EOFError):
                pass
                
    except KeyboardInterrupt:
        print("\n🛑 Interrompido pelo usuário")
    finally:
        client.disconnect()

if __name__ == "__main__":
    main()
