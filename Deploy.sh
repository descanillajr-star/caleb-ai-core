#!/bin/bash
set -e

echo "🚀 Deploying Caleb AI Core..."

apt update && apt upgrade -y
apt install -y git curl python3 python3-pip docker.io docker-compose ufw

systemctl enable docker
systemctl start docker

mkdir -p /opt/caleb_ai_core
cd /opt/caleb_ai_core

# Install Ollama (Offline AI)
if ! command -v ollama &> /dev/null; then
  curl -fsSL https://ollama.com/install.sh | sh
fi

ollama pull phi
ollama pull tinyllama

pip3 install fastapi uvicorn paho-mqtt vosk opencv-python faiss-cpu

cat << 'EOF' > ai_router.py
import socket

def internet():
    try:
        socket.create_connection(("8.8.8.8", 53), timeout=2)
        return True
    except:
        return False

def run(query):
    if internet():
        return "ONLINE AI MODE"
    return "OFFLINE AI MODE"

print("Caleb AI Core running")
EOF

cat << 'EOF' > /etc/systemd/system/caleb-ai.service
[Unit]
Description=Caleb AI Core
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/caleb_ai_core/ai_router.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable caleb-ai
systemctl start caleb-ai

ufw allow 22
ufw allow 8000
ufw --force enable

echo "✅ Caleb AI Core Installed Successfully"
