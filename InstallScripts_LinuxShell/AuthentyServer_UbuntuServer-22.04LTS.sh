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
chmod -R 777 /var/www/authentylocal
chown -R $USER:www-data /var/www/authentylocal
echo '''
<html>
    <head>
        <title>Bem-vindo a AuthentyLocal!</title>
    </head>
    <body>
        <h1>Sucesso!  Seu domínio virtual está funcionando!</h1>
    </body>
</html>
'''> /var/www/authentylocal/index.html
echo '''
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName authentylocal
    ServerAlias www.authentylocal
    DocumentRoot /var/www/authentylocal
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
''' > /etc/apache2/sites-available/authentylocal.conf
echo '''
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName authentylocal
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
cp /etc/vsftpd.conf /etc/vsftpd.conf.orig #cópia de segurança
echo '''

''' > /etc/vsftpd.conf
