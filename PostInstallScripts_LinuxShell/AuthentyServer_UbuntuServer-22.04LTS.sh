#!/bin/bash

## Execute diretamente usando:
## sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_LinuxShell/AuthentyServer_UbuntuServer-22.04LTS.sh)"

echo "
============================================================
            Welcome to the Ubuntu Post-Install Script       
============================================================
  Script: Ubuntu Server - Apache + PHP
  VERSÃO DO SISTEMA: Ubuntu Server 22.04 LTS
  Hardware: Virtualbox VM - 2GB RAM + 2vCPU
  Latest Version: 2024-07-31 10:27
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
	dpkg -i setup.deb
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
		apt install -y $SOFTWARE
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
apt dist-upgrade -y

# --------------------------------- Suporte a SSH -------------------------------------#
apt install -y openssh-server
service ssh start

# ---------------------------- Ativar Descoberta de Rede-------------------------------#
apt install -y avahi-daemon
systemctl start avahi-daemon
systemctl enable avahi-daemon

# ------------------------------ Ferramentas diversas ---------------------------------#
apt install -y net-tools glances

# ------------------------------------ Apache -----------------------------------------#
apt install -y apache2
ufw allow 'Apache'
ufw status

mkdir /var/www/authentylocal
chown -R $USER:$USER /var/www/authentylocal
chmod -R 777 /var/www/authentylocal
chown -R $USER:www-data /var/www/authentylocal
echo '''
<html>
    <head>
        <title>Bem-vindo a AuthentyLocal!</title>
    </head>
    <body>
        <h1>Sucesso!  Seu dominio virtual esta funcionando!</h1>
    </body>
</html>
'''> /var/www/authentylocal/index.html
echo '''
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName authenty.local      
    ServerAlias authenty.local
    DocumentRoot /var/www/authentylocal
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    AddDefaultCharset UTF-8

    <Directory /var/www/authentylocal>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

''' > /etc/apache2/sites-available/authentylocal.conf
echo '''
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName authenty.local
    ServerAlias authenty.local
    DocumentRoot /var/www/authentylocal
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateKeyFile /etc/ssl/private/ubuntu.authentylocal.key
    SSLCertificateFile /etc/ssl/certs/ubuntu.authentylocal.crt
    AddDefaultCharset UTF-8
</VirtualHost>
''' > /etc/apache2/sites-available/authentylocal-ssl.conf
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ubuntu.authentylocal.key -out /etc/ssl/certs/ubuntu.authentylocal.crt
a2ensite authentylocal.conf #Habilitar o arquivo novo como domínio. Para testar use: apache2ctl configtest
a2ensite authentylocal-ssl.conf
a2dissite 000-default.conf #desabilita o antigo
a2enmod ssl #ativar suporte à SSL
systemctl restart apache2 #reiniciando o apache

# ---------------------------------- FTP Server ---------------------------------------#
apt -y install vsftpd
systemctl start vsftpd
ufw allow 20/tcp
ufw allow 21/tcp
mv /etc/vsftpd.conf /etc/vsftpd.conf.orig #cópia de segurança
echo '''
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
xferlog_enable=YES
dirmessage_enable=YES
use_localtime=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
utf8_filesystem=YES
file_open_mode=0777
local_umask=022
# userlist_deny=NO
# userlist_enable=YES
# userlist_file=/etc/vsftpd.userlist
''' >> /etc/vsftpd.conf
/etc/init.d/vsftpd restart

# ---------------------------------- PHP Server ---------------------------------------#
apt install -y php libapache2-mod-php php-mysql php-mysqli php-curl php-mbstring php-xml composer

# --------------------------------- MySQL Server --------------------------------------#
apt -y install mysql-server
mysql_secure_installation #Instalação Gráfica
