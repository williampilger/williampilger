#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade

# Geral
sudo apt-get install -y net-tools gparted nmap guvcview
sudo apt-get install -y python3 python3-pip
sudo apt-get install -y git curl samba
sudo apt-get install -y wine winetricks playonlinux
sudo apt-get install -y obs-studio vlc
sudo apt-get install -y gimp inkscape imagemagick
sudo apt-get install -y filezilla
sudo apt-get install -y torbrowser-launcher

flatpak install flathub -y com.spotify.Client
flatpak install flathub -y com.getpostman.Postman
flatpak install flathub -y org.telegram.desktop
flatpak install flathub -y WhatsAppQT

sudo snap install flameshot
sudo snap install homeserver
sudo snap install code --classic

#Google Chrome
cd /home/$USER/Downloads
wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

#Discord (instalado via .deb pra ter compatibilidade com a captura de atividade)
cd /home/$USER/Downloads
wget -c https://discord.com/api/download?platform=linux&format=deb
sudo dpkg -i discord*.deb
rm discord*.deb

#Node JS
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs npm
npm install --global yarn


# Configurando SWAP Memory
cd /
sudo swapoff /swapfile #desativa SWAP
sudo rm /swapfile #Exclui arquivo velho
sudo fallocate -l 5G /swapfile #novo arquivo de 5GB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile #reativar SWAP




# Resta instalar manualmente
# VM Ware
# TeamViewer
# insync
# Virtual Box


# Wine GERAIL
winetricks dotnet48
