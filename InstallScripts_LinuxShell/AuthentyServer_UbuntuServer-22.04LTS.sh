#!/bin/bash
# ------------------------------------- INFO ------------------------------------------#
# SISTEMA: Ubuntu Server 22.04 LTS
# Post-install scrip para configurar servidor interno authenty
# Deve ser executado como Admin -> sudo ./script.sh

# ------------------------------------ Update -----------------------------------------#
apt-get update
apt-get upgrade -y
sudo apt dist-upgrade -y

# --------------------------------- Suporte a SSH -------------------------------------#
apt-get install -y openssh-server net-tools
service ssh start


# ------------------------------------ Apache -----------------------------------------#
apt-get install -y apache2
ufw allow 'Apache'
ufw status

mkdir /var/www/authentylocal
sudo chown -R $USER:$USER /var/www/authentylocal
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
    ServerName www.authentylocal.com.br
    ServerAlias www.authentylocal
    DocumentRoot /var/www/authentylocal
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
''' > /etc/apache2/sites-available/authentylocal.conf
echo '''
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName www.authentylocal.com.br
    ServerAlias www.authentylocal
    DocumentRoot /var/www/authentylocal
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateKeyFile /etc/ssl/private/ubuntu.authentylocal.key
    SSLCertificateFile /etc/ssl/certs/ubuntu.authentylocal.crt
</VirtualHost>
''' > /etc/apache2/sites-available/authentylocal-ssl.conf
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ubuntu.authentylocal.key -out /etc/ssl/certs/ubuntu.authentylocal.crt
a2ensite authentylocal.conf #Habilitar o arquivo novo como domínio. Para testar use: sudo apache2ctl configtest
a2ensite authentylocal-ssl.conf
a2dissite 000-default.conf #desabilita o antigo
a2enmod ssl #ativar suporte à SSL
systemctl restart apache2 #reiniciando o apache

# ---------------------------------- FTP Server ---------------------------------------#
apt-get -y install vsftpd
systemctl start vsftpd
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
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


# --------------------------------- MySQL Server --------------------------------------#
apt -y install mysql-server
mysql_secure_installation #Instalação Gráfica


