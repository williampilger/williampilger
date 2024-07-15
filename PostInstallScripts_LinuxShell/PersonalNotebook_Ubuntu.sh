#!/bin/bash
## VERSÃO DO SISTEMA: Ubuntu Pro - 24.04 LTS
## Latest Version: 2024-07-08 10:40
## Statistics: Tris script takes more than 1 hour (how about 1:10)

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

LOG '2212200909 - Start Script. Updating...'

sudo apt-get update
sudo apt-get -y upgrade
sudo apt --fix-broken install

LOG '2212200910 - Start System APPs instalation:'

APT_PROGRAMS=(
	# Geral
	net-tools
	gparted
	nmap
	guvcview
	samba
	xclip
	gdebi
	remmina
	p7zip
	p7zip-full
	p7zip-rar
	gnome-software-plugin-flatpakt
	transmission
	kdeconnect
	gnupg2
 	guvcview
  	cheese
   	btrfs-progs # suporte ao sistema de arquivos BTRFS
    	cryptsetup # suporte à criptografia de unidades
     	blueman
	# Codding
	python3
	python3-pip
	git
	curl
	filezilla
 	docker.io
  	docker-compose
   	nodejs
    	npm
	# OBS Studio
	obs-studio
	linux-headers-$(uname -r)
	v4l2loopback-dkms
	# Publicidade-Imagens-Edição
	gimp
	inkscape
	imagemagick
	vlc
 	flameshot
  	peek
	# Dependencias VMware
	gcc-6
	gcc-6-multilib
	linux-headers-$(uname -r)
	libx11-6
	libx11-dev
	xorg
	xorg-docs
	libxtst6
	psmisc
	build-essential
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

LOG '2212200912 - Start Snap APPs instalation:'

SNAP_PROGRAMS=(
	# Geral
#	homeserver
	brave
	spotify
	# Coding
	postman
	# Publicidade / Edição / Escritório
	onlyoffice-desktopeditors
	xournalpp
	# Comunicação
	telegram-desktop
)
for nome_do_programa in ${SNAP_PROGRAMS[@]}; do
	snap_install $nome_do_programa
done

LOG '2212201207 - Start .deb APPs instalation:'

DEB_PROGRAMS=(
	'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
	'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
#	'https://cdn.insynchq.com/builds/linux/insync_3.8.4.50481-jammy_amd64.deb'
#	'https://download.anydesk.com/linux/anydesk_6.3.1-1_amd64.deb'
)
for nome_do_programa in ${DEB_PROGRAMS[@]}; do
	deb_install $nome_do_programa
done


LOG '2212200913 - Start Custom instalations:'

# Gnome Extensions
gnome-extensions install --force gsconnect@andyholmes.github.io.zip


# Discord (instalado via .deb pra ter compatibilidade com a captura de atividade)
cd /home/$USER/Downloads
wget -O discord.deb 'https://discord.com/api/download?platform=linux&format=deb'
sudo dpkg -i discord.deb
apt --fix-broken install -y
rm discord.deb


LOG '2212200931 - Start Other configurations:'


# Firewall
sudo ufw enable
sudo ufw allow 3389 #RDP
sudo ufw allow 3390 #RDP viewonly

# Acesso SSH
sudo systemctl start ssh
sudo systemctl enable ssh
sudo ufw allow ssh


# Gnome COnfig (Para conferir, pode-se usar `dconf dump /` no terminal )
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
# Acesso Remoto
gsettings set org.gnome.desktop.remote-desktop.rdp enable true
gsettings set org.gnome.desktop.remote-desktop.rdp view-only true
gsettings set org.gnome.desktop.remote-desktop.rdp negotiate-port true
gsettings set org.gnome.desktop.remote-desktop.rdp screen-share-mode 'mirror-primary'
# Outros Diversos
gsettings set org.gnome.gedit.preferences.editor restore-session false

# Atalhos personalizados de teclado
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[\"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/\", \"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/\"]"
# abrir o Nautilus
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Open Nautilus"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "nautilus --new-window"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>F"
# abrir o monitor de recursos
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Open System Monitor"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "gnome-system-monitor"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Primary><Shift>Escape"


LOG '2212200938 - Post-install finished.'


# Resta instalar manualmente
# insync
# VMware
