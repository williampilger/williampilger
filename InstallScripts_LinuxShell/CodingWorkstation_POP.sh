#!/bin/bash
## VERSÃO DO SISTEMA: 22.04 LTS

sudo apt-get update
sudo apt-get -y upgrade

# Geral-Basico - DIVERSOS
sudo apt-get install -y net-tools gparted nmap guvcview samba xclip gdebi remmina
sudo apt-get install -y p7zip p7zip-full p7zip-rar
sudo apt-get install -y snapd
sudo snap install homeserver

# Geral-Basico - CODING
sudo apt-get install -y python3 python3-pip
sudo apt-get install -y git curl filezilla
flatpak install flathub -y com.getpostman.Postman
flatpak install flathub -y com.visualstudio.code

# Publicidade-Imagens-Edição
sudo apt-get install -y obs-studio vlc
sudo apt-get install -y gimp inkscape imagemagick
###sudo snap install flameshot
flatpak install flathub -y flameshot
flatpak install flathub -y org.onlyoffice.desktopeditors
flatpak install flathub -y com.github.xournalpp.xournalpp

# Comunicação-Social
###snap install telegram-desktop
flatpak install flathub -y WhatsAppQT
flatpak install flathub -y telegram-desktop

# Spotify
flatpak install flathub -y com.spotify.Client
###sudo snap install spotify

# Google Chrome
cd /home/$USER/Downloads
wget -c 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Discord (instalado via .deb pra ter compatibilidade com a captura de atividade)
cd /home/$USER/Downloads
wget -c 'https://discord.com/api/download?platform=linux&format=deb'
sudo dpkg -i discord.deb
apt --fix-broken install -y
rm discord*.deb

#Node JS
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get update
sudo apt --fix-broken install -y -f nodejs
sudo npm install --global yarn

#Wine
sudo apt-get install -y wine winetricks playonlinux
winetricks dotnet48


# Resta instalar manualmente
# VS Code (DEB. pois flatpack não funciona terminal)
# insync
# Virtual Box

# SSH Github
ssh-keygen -t ed25519 -C "GitHub - WilliamPilger - MICRO-02 - Escritório"
xclip -sel clip < ~/.ssh/id_ed25519.pub
