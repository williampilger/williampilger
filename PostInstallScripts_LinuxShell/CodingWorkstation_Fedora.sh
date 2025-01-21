#!/bin/bash

## Execute diretamente usando:
## bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_LinuxShell/CodingWorkstation_Fedora.sh)"

echo "
============================================================
            Welcome to the Fedora Post-Install Script       
============================================================
  Script: Codding Workstation Setup for Fedora
  Version: Adapted for Fedora
  Latest Version: $(date)
============================================================
"

LOG(){
	CONTENT=$1
	echo $(date) - $CONTENT >> LOG.txt
}

rpm_install(){
	URL=$1
	cd /home/$USER/Downloads
	wget -O setup.rpm "$URL"
	sudo dnf install -y ./setup.rpm
	if [ "$?" == 0 ]; then
		LOG "Successfully installed RPM '$URL'."
	else
		LOG "Failed to install RPM '$URL'."
	fi
	rm setup.rpm
}

dnf_install(){
	SOFTWARE=$1
	if ! rpm -q $SOFTWARE; then
		sudo dnf install -y $SOFTWARE
		if [ "$?" == 0 ]; then
			LOG "Successfully installed $SOFTWARE."
		else
			LOG "Failed to install $SOFTWARE."
		fi
	else
		LOG "$SOFTWARE is already installed."
	fi
}

flatpak_install(){
	SOFTWARE=$1
	flatpak install flathub -y $SOFTWARE
	if [ "$?" == 0 ]; then
		LOG "Successfully installed Flatpak $SOFTWARE."
	else
		LOG "Failed to install Flatpak $SOFTWARE."
	fi
}

LOG 'Start Script. Updating...'

sudo dnf update -y
sudo dnf upgrade -y

LOG 'Installing system applications:'

DNF_PROGRAMS=(
	# Geral
	net-tools
	openssh-server
	gparted
	nmap
	samba
	xclip
	remmina
	p7zip
	p7zip-plugins
	gnome-tweaks
	gnome-extensions-app
	flatpak
	transmission
	kdeconnect
	gnupg2
	blueman
	btrfs-progs
	cryptsetup
	bpytop
	# Coding
	python3
	python3-pip
	git
	curl
	filezilla
	docker
	docker-compose
	nodejs
	npm
	# OBS Studio
	obs-studio
	vlc
	flameshot
)
for nome_do_programa in ${DNF_PROGRAMS[@]}; do
	dnf_install $nome_do_programa
done

LOG 'Installing Flatpak applications:'

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
FLATPAK_PROGRAMS=(
	com.github.maoschanz.drawing
	io.github.lainsce.Colorway
	com.usebottles.bottles
	com.github.wwmm.easyeffects
	it.mijorus.gearlever
	io.podman_desktop.PodmanDesktop
	com.github.tchx84.Flatseal
)
for nome_do_programa in ${FLATPAK_PROGRAMS[@]}; do
	flatpak_install $nome_do_programa
done

LOG 'Installing .rpm applications:'

RPM_PROGRAMS=(
	'https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm'
	'https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64'
)
for nome_do_programa in ${RPM_PROGRAMS[@]}; do
	rpm_install $nome_do_programa
done

LOG 'Configuring firewall:'
sudo firewall-cmd --add-port=3389/tcp --permanent
sudo firewall-cmd --add-port=3390/tcp --permanent
sudo firewall-cmd --reload

LOG 'Configuring SSH:'
sudo systemctl enable sshd
sudo systemctl start sshd
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload

LOG 'Configuring Gnome settings:'
gsettings set org.gnome.desktop.interface text-scaling-factor 0.8
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 24

LOG 'Post-install finished.'
