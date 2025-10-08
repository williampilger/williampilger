#!/bin/bash

## Execute diretamente usando:
## sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_LinuxShell/GeneralDockerServer_UbuntuServer-22.04LTS.sh)"

echo "
============================================================
        Welcome to the Ubuntu Server Post-Install Script       
============================================================
  Script: Ubuntu Server + Docker
  VERSÃO DO SISTEMA: Ubuntu Server 22.04 LTS
  Hardware: Microsoft Hyper-V VM - 2GB RAM + 2vCPU
  Latest Version: 2025-10-00 18:21
              Author: Williampilger                         
============================================================
"

MACHINE_HOSTNAME='authenty'

LOG(){
	CONTENT=$1
	echo $(date) - $CONTENT >> LOG.txt
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

LOG '2212200909 - Start Script. Updating...'

apt update
apt upgrade -y
apt --fix-broken install

# ------------------------------ Ferramentas diversas ---------------------------------#
APT_PROGRAMS=(
	# Geral
	net-tools
 	openssh-server
	nmap
	p7zip
	p7zip-full
	p7zip-rar
   	btop
	# Codding
	python3
	python3-pip
	git
    git-lfs
	curl
 	docker.io
  	docker-compose
   	nodejs
   	npm
    httpie
	apt-transport-https
 	ca-certificates
  	gnupg
	gnupg2
 	terraform
	google-cloud-cli
)
for nome_do_programa in ${APT_PROGRAMS[@]}; do
	apt_install $nome_do_programa
done

# ----------------------------------- Firewall ----------------------------------------#
LOG '202407221022 - Start Firewall configuration'
sudo ufw allow ssh
sudo ufw allow from 192.168.0.0/24 to any port 5900 # VNC Local
sudo ufw allow 3000 # Normalmente usada para testar apps
sudo ufw allow 8080 # Normalmente usada para testar apps
sudo ufw allow 80 # HTTP
sudo ufw allow 443 # HTTPS
sudo ufw allow 3306 # MySQL/MariaDB
sudo ufw allow 5432 # PostgreSQL
sudo ufw allow 27017 # MongoDB
sudo ufw allow 6379 # Redis
sudo ufw enable

# --------------------------------- Suporte a SSH -------------------------------------#
LOG '202407221023 - Start SSH Access configuration'
sudo systemctl start ssh
sudo systemctl enable ssh

# ---------------------------- Ativar Descoberta de Rede-------------------------------#
LOG '202510081838 - Start Network Config'
sudo hostnamectl set-hostname $MACHINE_HOSTNAME
apt_install avahi-daemon
systemctl start avahi-daemon
systemctl enable avahi-daemon

# ------------------------------ Docker Configuration ---------------------------------#
LOG '202510081833 - Starting Docker configuration'
sudo usermod -aG docker $USER
newgrp docker #aplica logo as alterações

# ------------------------------------ LazyVim ----------------------------------------#
LOG '202510081830 - Lazy Vim Install'
bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/nvim/refs/heads/main/install.sh)"


LOG '2212200938 - Post-install finished.'