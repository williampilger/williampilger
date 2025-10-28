#!/bin/bash

## Execute diretamente usando:
## bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_LinuxShell/CoddingWorkStation_Ubuntu.sh)"

echo "
============================================================
            Welcome to the Ubuntu Post-Install Script       
============================================================
  Script: Codding Workstation Setup for Ubuntu
  VERSÃO DO SISTEMA: Xubuntu - 24.04 LTS
  Hardware: Acer Aspire 5
  Latest Version: 2025-10-26 13:00
  Statistics: Tris script takes less than 1 hour (depends on your internet connection, obviously)
              Author: Williampilger                         
============================================================

"

LOG(){
	CONTENT=$1
	echo $(date) - $CONTENT >> LOG.txt
}

deb_install(){
	URL=$1
	cd /home/$USER/Downloads
	wget -O setup.deb "$URL"
	sudo dpkg -i setup.deb
	if [ "$?" == 0 ]; then
		LOG "	2212201205 - Successfully install .DEB '$URL'."
	else
		LOG "	2212201206 - Impossible install .DEB '$URL'."
	fi
	rm setup.deb
}

apt_install(){
	SOFTWARE=$1
	if ! dpkg -l | grep -q $SOFTWARE; then
		sudo apt-get install -y $SOFTWARE
		if [ "$?" == 0 ]; then
			LOG "	2212200855 - Successfully install SYSTEM $SOFTWARE."
		else
			LOG "	2212200853 - Impossible install SYSTEM $SOFTWARE."
		fi
	else
		LOG "	2212200924 - Allready installed SYSTEM $SOFTWARE."
	fi
}

flatpack_install(){
	SOFTWARE=$1
	flatpak install flathub -y $SOFTWARE
	if [ "$?" == 0 ]; then
		LOG "	2212200905 - Successfully install FLATPACK $SOFTWARE."
	else
		LOG "	2212200906 - Impossible install FLATPACK $SOFTWARE."
	fi
}

snap_install(){
	SOFTWARE=$1
	sudo snap install $SOFTWARE
	if [ "$?" == 0 ]; then
		LOG "	2212200907 - Successfully install SNAP $SOFTWARE."
	else
		LOG "	2212200908 - Impossible install SNAP $SOFTWARE."
	fi
}

LOG '2507311331 - Add External Repositories'

# Terraform
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Google CLI
sudo curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list


LOG '2212200909 - Start Script. Updating...'

sudo apt-get update
sudo apt-get -y upgrade
sudo apt --fix-broken install

LOG '2212200910 - Start System APPs instalation:'

APT_PROGRAMS=(
	# Geral
	net-tools
 	openssh-server
	nmap
	guvcview
	samba
	xclip
	gdebi
	p7zip
	p7zip-full
	p7zip-rar
  	flatpak
	transmission
	kdeconnect
 	guvcview
  	cheese
   	btrfs-progs # suporte ao sistema de arquivos BTRFS
    	cryptsetup # suporte à criptografia de unidades
     	bpytop # ferramenta quase gráfica de terminal para monitorar o sistema
        rclone
	# Codding
	python3
	python3-pip
	git
        git-lfs
	curl
	filezilla
 	docker.io
  	docker-compose
   	nodejs
    	npm
     	tilix
        httpie
	apt-transport-https
 	ca-certificates
  	gnupg
	gnupg2
 	terraform
	google-cloud-cli
	# Publicidade-Imagens-Edição
	gimp
	inkscape
	imagemagick
	vlc
  	peek
   	flameshot
    	# Dependências OBS Studio
     	linux-headers-$(uname -r)
      	v4l2loopback-dkms
)
for nome_do_programa in ${APT_PROGRAMS[@]}; do
	apt_install $nome_do_programa
done


LOG '2212200911 - Start Flatpack APPs instalation:'
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
FLATPACK_PROGRAMS=(
	# Publicidade-Imagens-Edição
	com.github.maoschanz.drawing
	io.github.lainsce.Colorway
 	# OBS Studio (E tem configuação Extra no final)
  	com.obsproject.Studio
  	org.kde.Platform//5.15-21.08
	# Geral
	com.usebottles.bottles
	com.github.wwmm.easyeffects
	it.mijorus.gearlever #gerenciamento de AppImages
	io.podman_desktop.PodmanDesktop # Like Docker Desktop
	com.github.tchx84.Flatseal # ferramenta avançada para gerenciar os Flatpacks
)
for nome_do_programa in ${FLATPACK_PROGRAMS[@]}; do
	flatpack_install $nome_do_programa
done

# Configuração adicional do OBS Studio (para permitir a camera virtual)
sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="OBS-Camera" exclusive_caps=1
sudo flatpak override com.obsproject.Studio --device=all --filesystem=/dev/video0 --filesystem=/dev/video10

LOG '2212200912 - Start Snap APPs instalation:'

SNAP_PROGRAMS=(
	# Geral
 	homeserver
 	remmina
)
for nome_do_programa in ${SNAP_PROGRAMS[@]}; do
	snap_install $nome_do_programa
done

LOG '2212201207 - Start .deb APPs instalation:'

DEB_PROGRAMS=(
	'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
	'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
#	'https://cdn.insynchq.com/builds/linux/insync_3.8.4.50481-jammy_amd64.deb'
	'https://download3.ebz.epson.net/dsc/f/03/00/16/21/77/211c32cd14db04ed7838001a6ec0276e5ffd7190/epson-inkjet-printer-escpr_1.8.6-1_amd64.deb'
)
for nome_do_programa in ${DEB_PROGRAMS[@]}; do
	deb_install $nome_do_programa
done
apt --fix-broken install -y # necessário pro discord, por algum motivo desconhecido

LOG '250926144301 - Start Drivers auto-install:'

sudo ubuntu-drivers autoinstall

LOG '2212200913 - Start Custom instalations:'

# 'Abrir com Code' no menu de contexto do Nautilus
wget -qO- https://raw.githubusercontent.com/williampilger/code-nautilus/master/install.sh | bash

# Pomodoro Timer
bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/PomodoroTimer-Python/main/install.sh)"

# Instalando o LazyVim
bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/nvim/refs/heads/main/install.sh)"

# Acesso SSH
LOG '202407221023 - Start SSH Access configuration'
sudo systemctl start ssh
sudo systemctl enable ssh

# Firewall
LOG '202407221022 - Start Firewall configuration'
# Usando /16 pra permitir todos 192.168.X.X
sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp
sudo ufw allow from 192.168.0.0/16 to any port 80 proto tcp # HTTP
sudo ufw allow from 192.168.0.0/16 to any port 443 proto tcp # HTTPS
sudo ufw allow from 192.168.0.0/16 to any port 3389 proto tcp # RDP
sudo ufw allow from 192.168.0.0/16 to any port 3390 proto tcp # VNC Viewonly
sudo ufw allow from 192.168.0.0/16 to any port 5900 proto tcp # VNC
sudo ufw allow from 192.168.0.0/16 to any port 3000:3010 proto tcp # APPS tests
sudo ufw allow from 192.168.0.0/16 to any port 8080 proto tcp # APPS tests
sudo ufw enable

# Docker Configuration
sudo usermod -aG docker $USER
newgrp docker #aplica logo as alterações

# Wake-up-on-LAN
LOG '202407221026 - Configuring Wake-Up-On-LAN'
INTERFACE="enp1s0"
sudo ethtool -s $INTERFACE wol g #isso só afeta para a inicialização atual, não é persistido. Abaixo fazendo a alteração que, de fatp, vai ficar
sudo bash -c "cat > /etc/netplan/01-netcfg.yaml <<EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: yes
      wakeonlan: true
EOF"
sudo netplan apply
sudo bash -c "cat > /etc/systemd/system/wol.service <<EOF
[Unit]
Description=Configure Wake-on-LAN

[Service]
ExecStart=/usr/sbin/ethtool -s $INTERFACE wol g

[Install]
WantedBy=multi-user.target
EOF"
sudo systemctl enable wol.service
sudo systemctl start wol.service





LOG '2212200938 - Post-install finished.'