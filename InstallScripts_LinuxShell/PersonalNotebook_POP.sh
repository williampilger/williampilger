#!/bin/bash
## VERSÃO DO SISTEMA: POP! OS - 22.04 LTS

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
	snapd
	transmission
	# Codding
	python3
	python3-pip
	git
	curl
	filezilla
	# OBS Studio
	obs-studio
	linux-headers-$(uname -r)
	v4l2loopback-dkms
	# Publicidade-Imagens-Edição
	gimp
	inkscape
	imagemagick
	vlc
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

FLATPACK_PROGRAMS=(
	# Codding
	com.getpostman.Postman
#	com.visualstudio.code
	org.kde.kcolorchooser
	md.obsidian.Obsidian
	# Publicidade-Imagens-Edição
	flameshot
	org.onlyoffice.desktopeditors
	com.github.xournalpp.xournalpp
	com.uploadedlobster.peek
	com.github.maoschanz.drawing
	# Comunicação-Social
	org.telegram.desktop
	io.github.mimbrero.WhatsAppDesktop
	# Geral
	com.usebottles.bottles
	com.spotify.Client
)
for nome_do_programa in ${FLATPACK_PROGRAMS[@]}; do
	flatpack_install $nome_do_programa
done

LOG '2212200912 - Start Snap APPs instalation:'

SNAP_PROGRAMS=(
	# Geral
	homeserver
)
for nome_do_programa in ${SNAP_PROGRAMS[@]}; do
	snap_install $nome_do_programa
done

LOG '2212201207 - Start .deb APPs instalation:'

DEB_PROGRAMS=(
	'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
	'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
	'https://cdn.insynchq.com/builds/linux/insync_3.8.4.50481-jammy_amd64.deb'
)
for nome_do_programa in ${DEB_PROGRAMS[@]}; do
	deb_install $nome_do_programa
done


LOG '2212200913 - Start Custom instalations:'


# Discord (instalado via .deb pra ter compatibilidade com a captura de atividade)
cd /home/$USER/Downloads
wget -O discord.deb 'https://discord.com/api/download?platform=linux&format=deb'
sudo dpkg -i discord.deb
apt --fix-broken install -y
rm discord.deb

#Node JS
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get update
sudo apt --fix-broken install -y -f nodejs
sudo npm install --global yarn



LOG '2212200931 - Start Other configurations:'


# SSH Github
ssh-keygen -t ed25519 -C "GitHub - WilliamPilger - Notebook Acer Aspire 5"
xclip -sel clip < ~/.ssh/id_ed25519.pub
LOG "NEW SSH KEYPAIR GENERATED: $(cat ~/.ssh/id_ed25519.pub)"
git config --global user.email "pilger.will@gmail.com"
git config --global user.name "williampilger"


LOG '2212200938 - Post-install finished.'


# Resta instalar manualmente
# insync
# VMware
