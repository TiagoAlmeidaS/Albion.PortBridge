#!/usr/bin/env python3
"""
Servidor UDP de teste para simular o serviço Crypto local
Execute: python test/test-udp-server-5051.py
"""

import socket
import threading
import time
import json
from datetime import datetime

class TestCryptoUDPServer:
    def __init__(self, host='127.0.0.1', port=5051):
        self.host = host
        self.port = port
        self.server_socket = None
        self.running = False
        self.clients = set()
        
    def start(self):
        """Inicia o servidor UDP de teste"""
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.server_socket.bind((self.host, self.port))
            
            self.running = True
            print(f"🚀 Servidor UDP de teste Crypto iniciado em {self.host}:{self.port}")
            print(f"📡 Aguardando pacotes UDP...")
            print(f"🔗 Teste via: python test/test-udp.py")
            print(f"🛑 Pressione Ctrl+C para parar")
            
            # Thread para heartbeat
            heartbeat_thread = threading.Thread(target=self.heartbeat)
            heartbeat_thread.daemon = True
            heartbeat_thread.start()
            
            try:
                while self.running:
                    # Recebe dados
                    data, addr = self.server_socket.recvfrom(1024)
                    if not self.running:
                        break
                        
                    # Processa mensagem
                    self.handle_message(data, addr)
                    
            except KeyboardInterrupt:
                print("\n🛑 Servidor sendo encerrado...")
                
        except Exception as e:
            print(f"❌ Erro ao iniciar servidor: {e}")
        finally:
            self.stop()
    
    def handle_message(self, data, addr):
        """Processa mensagem recebida"""
        try:
            message = data.decode().strip()
            print(f"📥 [{addr}] Recebido: {message}")
            
            # Adiciona cliente à lista
            self.clients.add(addr)
            
            # Simula processamento do Crypto
            response = self.process_crypto_message(message)
            
            # Envia resposta
            self.server_socket.sendto(response.encode(), addr)
            print(f"📤 [{addr}] Enviado: {response}")
            
        except Exception as e:
            print(f"❌ Erro ao processar mensagem de {addr}: {e}")
    
    def process_crypto_message(self, message):
        """Simula processamento de mensagem do Crypto"""
        try:
            # Tenta fazer parse JSON
            data = json.loads(message)
            
            # Simula diferentes tipos de resposta baseado no tipo
            if data.get("type") == "ping":
                return json.dumps({
                    "type": "pong",
                    "timestamp": datetime.now().isoformat(),
                    "latency": "0ms",
                    "server": "TestCryptoUDPServer-5051"
                })
            elif data.get("type") == "crypto_request":
                return json.dumps({
                    "type": "crypto_response",
                    "status": "success",
                    "data": "Dados criptografados simulados",
                    "timestamp": datetime.now().isoformat(),
                    "server": "TestCryptoUDPServer-5051"
                })
            elif data.get("type") == "login":
                return json.dumps({
                    "type": "login_response",
                    "status": "authenticated",
                    "session_id": "test_session_123",
                    "timestamp": datetime.now().isoformat(),
                    "server": "TestCryptoUDPServer-5051"
                })
            else:
                return json.dumps({
                    "type": "echo",
                    "original_message": message,
                    "timestamp": datetime.now().isoformat(),
                    "server": "TestCryptoUDPServer-5051"
                })
                
        except json.JSONDecodeError:
            # Se não for JSON, retorna echo
            return json.dumps({
                "type": "echo",
                "original_message": message,
                "timestamp": datetime.now().isoformat(),
                "server": "TestCryptoUDPServer-5051"
            })
    
    def heartbeat(self):
        """Envia heartbeat para clientes conectados"""
        while self.running:
            try:
                time.sleep(30)  # A cada 30 segundos
                
                if self.clients:
                    heartbeat_msg = {
                        "type": "heartbeat",
                        "timestamp": datetime.now().isoformat(),
                        "clients_connected": len(self.clients),
                        "server": "TestCryptoUDPServer-5051"
                    }
                    
                    # Remove clientes inativos
                    inactive_clients = set()
                    for client in self.clients:
                        try:
                            self.server_socket.sendto(json.dumps(heartbeat_msg).encode(), client)
                        except:
                            inactive_clients.add(client)
                    
                    # Remove clientes inativos
                    self.clients -= inactive_clients
                        
                    if inactive_clients:
                        print(f"🧹 {len(inactive_clients)} clientes inativos removidos")
                        
            except Exception as e:
                print(f"❌ Erro no heartbeat: {e}")
    
    def stop(self):
        """Para o servidor"""
        self.running = False
        
        # Fecha socket do servidor
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        
        print("✅ Servidor UDP de teste encerrado")

if __name__ == "__main__":
    server = TestCryptoUDPServer()
    server.start()
