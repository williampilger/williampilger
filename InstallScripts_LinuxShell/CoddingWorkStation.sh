#!/bin/bash
sudo su

apt-get update
apt-get -y upgrade

# Geral-Basico - REDE
apt-get install -y net-tools gparted nmap guvcview samba

# Geral-Basico - CODING
apt-get install -y python3 python3-pip
apt-get install -y git curl filezilla
flatpak install flathub -y com.getpostman.Postman
snap install code --classic

# Publicidade-Imagens-Edição
apt-get install -y obs-studio vlc
apt-get install -y gimp inkscape imagemagick
snap install flameshot

# Arquivos
snap install homeserver

# Comunicação-Social
flatpak install flathub -y org.telegram.desktop
###flatpak install flathub -y WhatsAppQT

# Spotify
flatpak install flathub -y com.spotify.Client

# Google Chrome
cd /home/$USER/Downloads
wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Discord (instalado via .deb pra ter compatibilidade com a captura de atividade)
cd /home/$USER/Downloads
wget -c https://discord.com/api/download?platform=linux&format=deb
dpkg -i discord*.deb
rm discord*.deb

#Node JS
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
apt-get install -y nodejs npm
npm install --global yarn

#Wine
apt-get install -y wine winetricks playonlinux
winetricks dotnet48


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

