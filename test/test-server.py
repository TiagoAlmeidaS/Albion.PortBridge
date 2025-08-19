#!/usr/bin/env python3
"""
Servidor de teste para simular o serviço Crypto local
Execute: python test/test-server.py
"""

import socket
import threading
import time
import json
from datetime import datetime

class TestCryptoServer:
    def __init__(self, host='127.0.0.1', port=5050):
        self.host = host
        self.port = port
        self.server_socket = None
        self.clients = []
        self.running = False
        
    def start(self):
        """Inicia o servidor de teste"""
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(5)
            
            self.running = True
            print(f"🚀 Servidor de teste Crypto iniciado em {self.host}:{self.port}")
            print(f"📡 Aguardando conexões...")
            print(f"🔗 Conecte via: telnet {self.host} {self.port}")
            
            # Thread para aceitar conexões
            accept_thread = threading.Thread(target=self.accept_connections)
            accept_thread.daemon = True
            accept_thread.start()
            
            # Thread para heartbeat
            heartbeat_thread = threading.Thread(target=self.heartbeat)
            heartbeat_thread.daemon = True
            heartbeat_thread.start()
            
            try:
                while self.running:
                    time.sleep(1)
            except KeyboardInterrupt:
                print("\n🛑 Servidor sendo encerrado...")
                
        except Exception as e:
            print(f"❌ Erro ao iniciar servidor: {e}")
        finally:
            self.stop()
    
    def accept_connections(self):
        """Aceita conexões de clientes"""
        while self.running:
            try:
                client_socket, address = self.server_socket.accept()
                print(f"🔗 Nova conexão de {address}")
                
                # Thread para cada cliente
                client_thread = threading.Thread(
                    target=self.handle_client, 
                    args=(client_socket, address)
                )
                client_thread.daemon = True
                client_thread.start()
                
                self.clients.append(client_socket)
                
            except Exception as e:
                if self.running:
                    print(f"❌ Erro ao aceitar conexão: {e}")
    
    def handle_client(self, client_socket, address):
        """Gerencia comunicação com um cliente"""
        try:
            # Envia mensagem de boas-vindas
            welcome_msg = {
                "type": "welcome",
                "message": "Bem-vindo ao servidor de teste Crypto!",
                "timestamp": datetime.now().isoformat(),
                "server": "TestCryptoServer",
                "version": "1.0.0"
            }
            client_socket.send((json.dumps(welcome_msg) + "\n").encode())
            
            while self.running:
                try:
                    # Recebe dados do cliente
                    data = client_socket.recv(1024)
                    if not data:
                        break
                    
                    message = data.decode().strip()
                    print(f"📥 [{address}] Recebido: {message}")
                    
                    # Simula processamento do Crypto
                    response = self.process_crypto_message(message)
                    
                    # Envia resposta
                    client_socket.send((response + "\n").encode())
                    print(f"📤 [{address}] Enviado: {response}")
                    
                except Exception as e:
                    print(f"❌ Erro na comunicação com {address}: {e}")
                    break
                    
        except Exception as e:
            print(f"❌ Erro ao gerenciar cliente {address}: {e}")
        finally:
            if client_socket in self.clients:
                self.clients.remove(client_socket)
            client_socket.close()
            print(f"🔚 Cliente {address} desconectado")
    
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
                    "latency": "0ms"
                })
            elif data.get("type") == "crypto_request":
                return json.dumps({
                    "type": "crypto_response",
                    "status": "success",
                    "data": "Dados criptografados simulados",
                    "timestamp": datetime.now().isoformat()
                })
            else:
                return json.dumps({
                    "type": "echo",
                    "original_message": message,
                    "timestamp": datetime.now().isoformat()
                })
                
        except json.JSONDecodeError:
            # Se não for JSON, retorna echo
            return json.dumps({
                "type": "echo",
                "original_message": message,
                "timestamp": datetime.now().isoformat()
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
                        "clients_connected": len(self.clients)
                    }
                    
                    # Remove clientes desconectados
                    disconnected_clients = []
                    for client in self.clients:
                        try:
                            client.send((json.dumps(heartbeat_msg) + "\n").encode())
                        except:
                            disconnected_clients.append(client)
                    
                    for client in disconnected_clients:
                        if client in self.clients:
                            self.clients.remove(client)
                        client.close()
                        
                    if disconnected_clients:
                        print(f"🧹 {len(disconnected_clients)} clientes desconectados removidos")
                        
            except Exception as e:
                print(f"❌ Erro no heartbeat: {e}")
    
    def stop(self):
        """Para o servidor"""
        self.running = False
        
        # Fecha conexões com clientes
        for client in self.clients:
            try:
                client.close()
            except:
                pass
        self.clients.clear()
        
        # Fecha socket do servidor
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        
        print("✅ Servidor de teste encerrado")

if __name__ == "__main__":
    server = TestCryptoServer()
    server.start()
