#!/bin/bash
## VERSÃO DO SISTEMA: 22.04 LTS
sudo su

apt-get update
apt-get -y upgrade

# Geral-Basico - DIVERSOS
apt-get install -y net-tools gparted gnome-tweaks nmap guvcview samba xclip gdebi
apt-get install -y p7zip p7zip-full p7zip-rar
apt-get install -y flatpack #evitar de usar flatpacks
snap install homeserver

# Geral-Basico - CODING
apt-get install -y python3 python3-pip
apt-get install -y git curl filezilla
snap install postman
snap install code --classic

# Publicidade-Imagens-Edição
apt-get install -y obs-studio vlc
apt-get install -y gimp inkscape imagemagick
snap install flameshot

# Comunicação-Social
snap install telegram-desktop
###flatpak install flathub -y WhatsAppQT

# Spotify
###flatpak install flathub -y com.spotify.Client
snap install spotify

# Google Chrome
cd /home/$USER/Downloads
wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Discord (instalado via .deb pra ter compatibilidade com a captura de atividade)
cd /home/$USER/Downloads
wget -c https://discord.com/api/download?platform=linux&format=deb
dpkg -i discord*.deb
apt --fix-broken install -y
rm discord*.deb

#Node JS
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
apt-get update
apt --fix-broken install -y -f nodejs
npm install --global yarn

#Wine
apt-get install -y wine winetricks playonlinux
winetricks dotnet48



# Resta instalar manualmente
# insync
# Virtual Box

