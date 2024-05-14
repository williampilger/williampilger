@echo off
SETLOCAL EnableDelayedExpansion

choco install -y git
choco install -y nodejs-lts
choco install -y vscode
choco install -y docker-desktop
choco install -y python
choco install -y wget
choco install -y curl
choco install -y googlechrome

echo Todos os pacotes foram instalados com sucesso.
pause