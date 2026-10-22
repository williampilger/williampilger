#!/bin/bash

## Execute diretamente usando:
## bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_LinuxShell/CodingWorkStation_Ubuntu.sh)"

echo "
============================================================
            Welcome to the Ubuntu Post-Install Script       
============================================================
  Script: Light Domestic Notebook Setup for Ubuntu
  VERSÃO DO SISTEMA: Ubuntu - 26.04 LTS
  Hardware: 
  Latest Version: 2026-10-19
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
	apt --fix-broken install -y
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

LOG '2607161031 - Add Primeiras Dependências'

sudo apt update
sudo apt install -y ca-certificates apt-transport-https curl

LOG '2507311331 - Add External Repositories'

# Docker (GPG Keys + Repo
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  
LOG '2212200909 - Start Script. Updating...'

sudo apt update
sudo apt -y upgrade
sudo apt --fix-broken install

LOG '2212200910 - Start System APPs instalation:'

APT_PROGRAMS=(
	# Geral
	net-tools
 	openssh-server
	gparted
	nmap
	guvcview
	samba
	xclip
	gdebi
	p7zip
	p7zip-full
	p7zip-rar
	gnome-software-plugin-flatpak
 	gnome-shell-extensions
	ubuntu-drivers-common
  	flatpak
	transmission
	kdeconnect
  	cheese
   	btrfs-progs # suporte ao sistema de arquivos BTRFS
	cryptsetup # suporte à criptografia de unidades
	# Codding
	python3
	python3-pip
	python3-tk
	python3-venv
	git
	git-lfs
	filezilla
	gnupg
	gnupg2
	google-cloud-cli
	mysql-client-core
	# Docker
	docker-ce
	docker-ce-cli
	containerd.io
	docker-buildx-plugin
	docker-compose-plugin
	# Publicidade-Imagens-Edição
	gimp
	inkscape
	imagemagick
	vlc
	peek
	flameshot
)
for nome_do_programa in ${APT_PROGRAMS[@]}; do
	apt_install $nome_do_programa
done


LOG '2212200911 - Start Flatpack APPs instalation:'
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
FLATPACK_PROGRAMS=(
	# Publicidade-Imagens-Edição
	com.github.maoschanz.drawing
	# Geral
	it.mijorus.gearlever #gerenciamento de AppImages
	com.github.tchx84.Flatseal # ferramenta avançada para gerenciar os Flatpacks
)
for nome_do_programa in ${FLATPACK_PROGRAMS[@]}; do
	flatpack_install $nome_do_programa
done

LOG '2212200912 - Start Snap APPs instalation:'

SNAP_PROGRAMS=(
	# Geral
 	homeserver
	brave
 	remmina
	# Publicidade / Edição / Escritório
	onlyoffice-desktopeditors
)
for nome_do_programa in ${SNAP_PROGRAMS[@]}; do
	snap_install $nome_do_programa
done

LOG '2607161042 - NVM e Node Install:'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # ISSO SERVE PRA O NVM JÁ FUNCIONAR IMEDIATAMENTE
nvm install 22
nvm use 22
nvm alias default 22
npm install -g pm2

LOG '2212201207 - Start .deb APPs instalation:'

DEB_PROGRAMS=(
	'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
	'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
	'https://cdn.insynchq.com/builds/linux/insync_3.8.4.50481-jammy_amd64.deb'
	'https://download3.ebz.epson.net/dsc/f/03/00/16/21/77/211c32cd14db04ed7838001a6ec0276e5ffd7190/epson-inkjet-printer-escpr_1.8.6-1_amd64.deb'
 	'https://discord.com/api/download?platform=linux&format=deb'
	'https://mega.nz/linux/repo/xUbuntu_26.04/amd64/megasync-xUbuntu_26.04_amd64.deb'
)
for nome_do_programa in ${DEB_PROGRAMS[@]}; do
	deb_install $nome_do_programa
done

LOG '250926144301 - Start Drivers auto-install:'

sudo ubuntu-drivers autoinstall

LOG '2212200913 - Start Custom instalations:'

# 'Abrir com Code' no menu de contexto do Nautilus
wget -qO- https://raw.githubusercontent.com/williampilger/code-nautilus/master/install.sh | bash

# Sicredi Warsaw
wget -O warsaw.run "https://si-plg.sicredi.com.br/warsaw-ubuntu.run"
chmod +x warsaw.run
sudo ./warsaw.run
rm warsaw.run

LOG '2407111129 - Start Gnome Extensions Instalation:'
# ATENÇÃO: este script de terceiros pode não ser confiável... mas não existe uma forma "oficial" de fazer isso
sudo wget -O /usr/local/bin/gnome-shell-extension-installer https://raw.githubusercontent.com/brunelli/gnome-shell-extension-installer/master/gnome-shell-extension-installer
sudo chmod +x /usr/local/bin/gnome-shell-extension-installer
gnome-shell-extension-installer 6242 # Instalando Emogi Copy
gnome-extensions enable emoji-copy@felipeftn

# Acesso SSH
LOG '202407221023 - Start SSH Access configuration'
sudo systemctl start ssh
sudo systemctl enable ssh
# Instalando o Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
# Depois, é necessário dar um `tailscale up` e fazer login. Ou, usar a chave da Authenty, assim:
#sudo tailscale up --authkey=tskey-auth-SAMPLESAMPLESAMPLE-SAMPLESAMPLESAMPLESAMPLESAMPLESAMPLE

# Firewall
LOG '202407221022 - Start Firewall configuration'
# Usando /16 pra permitir todos 192.168.X.X
sudo ufw allow from 192.168.0.0/16 to any
sudo ufw allow from 172.17.0.0/16 to any
sudo ufw allow from 100.64.0.0/10 to any
sudo ufw enable

# Docker user Configuration
sudo usermod -aG docker $USER

# Gnome COnfig (Para conferir, pode-se usar `dconf dump /` no terminal )
LOG '202407221024 - Start Gnome configuration'
gsettings set org.gnome.desktop.interface text-scaling-factor 0.8 # System Text Scalling
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-olive-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-olive'
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.mutter edge-tiling false
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set org.gnome.shell.app-switcher current-workspace-only true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 24
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>t']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Control><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Control><Super>Right']"
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop']"
# Outros Diversos
gsettings set org.gnome.gedit.preferences.editor restore-session false
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'suspend'

# Atalhos personalizados de teclado
LOG '202407221025 - Start Keybinding configuration'
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[\"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/\", \"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/\"]"
# abrir o Nautilus
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Open Nautilus"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "nautilus --new-window"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>F"
# abrir o monitor de recursos
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Open System Monitor"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "gnome-system-monitor"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Primary><Shift>Escape"

# Acesso remoto por RDP
#sudo adduser xrdp ssl-cert# Adicionar xrdp ao grupo ssl-cert (obrigatório no Ubuntu moderno)
#sudo systemctl enable --now xrdp

LOG '20251216155505 - Configurações gerais do sistema'
sudo journalctl --vacuum-size=500M #limitando os LOGs do sistema a 500MB


LOG '2212200938 - Post-install finished.'
