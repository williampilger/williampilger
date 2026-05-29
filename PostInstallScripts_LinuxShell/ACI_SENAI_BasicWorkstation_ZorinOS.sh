#!/bin/bash

## Execute diretamente usando:
## bash -c "$(curl -fsSL https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_LinuxShell/ACI_SENAI_BasicWorkstation_ZorinOS.sh)"

ALUNO_USERNAME="aluno"
ALUNO_FULLNAME="Aluno"
ALUNO_HOME="/home/$ALUNO_USERNAME"

echo "
============================================================
       ACI/SENAI - Script de Pos-Instalacao Zorin OS
============================================================
  Script: Estacao de Trabalho Basica - ACI/SENAI
  VERSAO DO SISTEMA: Zorin OS 17 (base Ubuntu 22.04 LTS)
  Ultima atualizacao: 2026-05-26
  Autor: Williampilger

  O usuario administrador é o proprio usuario do sistema
  criado durante a instalacao do Zorin OS.
  Este script cria apenas o usuario 'aluno'.
============================================================
  USUARIO ALUNO:
    Login    : aluno
    Senha    : nenhuma (login automatico ativo)
    Acesso   : sem sudo, sem configuracoes de rede ou sistema

  APLICATIVOS INSTALADOS:
    - Firefox            (via Mozilla PPA)
    - Google Chrome
    - OnlyOffice Desktop

  ADMINISTRACAO:
    Desativar autologin (Zorin Core):  sudo nano /etc/gdm3/custom.conf
    Desativar autologin (Zorin Lite):  sudo nano /etc/lightdm/lightdm.conf
============================================================
"

read -p "Confirmar e iniciar instalacao? [S/n]: " CONFIRM
[[ "$CONFIRM" =~ ^[Nn] ]] && { echo "Cancelado."; exit 1; }

# ─── Funcoes Auxiliares ───────────────────────────────────────────────────────

LOG(){
	CONTENT=$1
	echo "$(date) - $CONTENT" | tee -a LOG.txt
}

apt_install(){
	SOFTWARE=$1
	if ! dpkg -s "$SOFTWARE" &>/dev/null; then
		sudo apt-get install -y "$SOFTWARE"
		if [ "$?" == 0 ]; then
			LOG "APT instalado com sucesso: $SOFTWARE"
		else
			LOG "ERRO ao instalar APT: $SOFTWARE"
		fi
	else
		LOG "APT ja instalado: $SOFTWARE"
	fi
}

snap_install(){
	SOFTWARE=$1
	if ! snap list "$SOFTWARE" &>/dev/null; then
		sudo snap install "$SOFTWARE"
		if [ "$?" == 0 ]; then
			LOG "SNAP instalado com sucesso: $SOFTWARE"
		else
			LOG "ERRO ao instalar SNAP: $SOFTWARE"
		fi
	else
		LOG "SNAP ja instalado: $SOFTWARE"
	fi
}

deb_install(){
	URL=$1
	TMP_DEB="/tmp/pkg_$$.deb"
	wget -O "$TMP_DEB" "$URL"
	sudo dpkg -i "$TMP_DEB"
	sudo apt-get -f install -y
	if [ "$?" == 0 ]; then
		LOG "DEB instalado com sucesso: $URL"
	else
		LOG "ERRO ao instalar DEB: $URL"
	fi
	rm -f "$TMP_DEB"
}

# ─── Atualizacao do Sistema ───────────────────────────────────────────────────

LOG "2026052601 - Atualizando sistema"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt --fix-broken install -y

# ─── Dependencias Gerais ──────────────────────────────────────────────────────

LOG "2026052602 - Instalando dependencias gerais"
for pkg in curl wget gdebi openssh-server ufw; do
	apt_install "$pkg"
done

# ─── Firefox (via Mozilla PPA — versao nativa apt, nao snap) ─────────────────

LOG "2026052603 - Instalando Firefox"
sudo add-apt-repository ppa:mozillateam/ppa -y
printf 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' \
	| sudo tee /etc/apt/preferences.d/mozilla-firefox > /dev/null
sudo apt-get update -y
apt_install firefox

# ─── Google Chrome ────────────────────────────────────────────────────────────

LOG "2026052604 - Instalando Google Chrome"
deb_install 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
LOG "2026052613 - Configurando Chrome para nao usar GNOME Keyring"
sudo mkdir -p /etc/opt/chrome/policies/managed
sudo tee /etc/opt/chrome/policies/managed/senai-aluno.json > /dev/null <<'CHROMEEOF'
{
  "PasswordManagerEnabled": false
}
CHROMEEOF


# ─── OnlyOffice Desktop Editors ───────────────────────────────────────────────

LOG "2026052605 - Instalando OnlyOffice Desktop Editors"
snap_install onlyoffice-desktopeditors

# ─── Usuario Aluno ────────────────────────────────────────────────────────────

LOG "2026052606 - Criando usuario aluno: $ALUNO_USERNAME"
if id "$ALUNO_USERNAME" &>/dev/null; then
	LOG "Usuario $ALUNO_USERNAME ja existe."
else
	sudo useradd -m -s /bin/bash -c "$ALUNO_FULLNAME" "$ALUNO_USERNAME"
	sudo passwd -d "$ALUNO_USERNAME"
	LOG "Usuario $ALUNO_USERNAME criado sem senha."
fi

# ─── Bloqueio: aluno nao pode definir senha via terminal ─────────────────────
#
#  Wrapper em /usr/local/bin/passwd (tem precedencia sobre /usr/bin/passwd no PATH).
#  Verifica whoami, entao admins (root) nao sao afetados.

LOG "2026052607 - Configurando bloqueio de senha via terminal para $ALUNO_USERNAME"
sudo tee /usr/local/bin/passwd > /dev/null <<WRAPEOF
#!/bin/bash
if [ "\$(whoami)" = "aluno" ]; then
	echo "Erro: este usuario nao tem permissao para definir ou alterar senhas." >&2
	exit 1
fi
exec /usr/bin/passwd "\$@"
WRAPEOF
sudo chmod 755 /usr/local/bin/passwd

# ─── Restricoes Polkit para o Usuario Aluno ───────────────────────────────────
#
#  Bloqueia via interface grafica:
#    - Configuracoes de rede (NetworkManager)
#    - Gerenciamento de contas e senhas
#    - Data, hora, idioma e hostname
#    - Instalacao de pacotes
#    - Administracao de impressoras

LOG "2026052608 - Configurando restricoes polkit para $ALUNO_USERNAME"
sudo tee /etc/polkit-1/rules.d/50-aluno-restrictions.rules > /dev/null <<'POLKITEOF'
// Restricoes ACI/SENAI — usuario 'aluno'
polkit.addRule(function(action, subject) {
	if (subject.user === "aluno") {

		// Configuracoes de rede
		if (action.id.indexOf("org.freedesktop.NetworkManager") === 0)
			return polkit.Result.NO;

		// Gerenciamento de contas e senhas
		if (action.id.indexOf("org.freedesktop.accounts") === 0)
			return polkit.Result.NO;

		// Data e hora
		if (action.id.indexOf("org.freedesktop.timedate1") === 0)
			return polkit.Result.NO;

		// Idioma e localizacao
		if (action.id.indexOf("org.freedesktop.locale1") === 0)
			return polkit.Result.NO;

		// Nome do computador
		if (action.id.indexOf("org.freedesktop.hostname1") === 0)
			return polkit.Result.NO;

		// Instalacao e remocao de pacotes
		if (action.id.indexOf("org.freedesktop.packagekit") === 0)
			return polkit.Result.NO;

		// Administracao de impressoras
		if (action.id.indexOf("com.ubuntu.printermanager") === 0)
			return polkit.Result.NO;
	}
});
POLKITEOF

# ─── dconf: trava bloqueio de tela ────────────────────────────────────────────
#
#  Impede aluno de reativar o bloqueio de tela via Configuracoes do GNOME.
#  O perfil 'aluno' aponta para a system-db 'senai', que contem o lock.
#  DCONF_PROFILE e definido via environment.d para cobrir Wayland e X11.

LOG "2026052609 - Configurando dconf para bloquear bloqueio de tela do $ALUNO_USERNAME"

sudo mkdir -p /etc/dconf/db/senai.d/locks

sudo tee /etc/dconf/db/senai.d/00-aluno-defaults > /dev/null <<'DCONFEOF'
[org/gnome/desktop/screensaver]
lock-enabled=false

[org/gnome/desktop/session]
idle-delay=uint32 900
DCONFEOF

sudo tee /etc/dconf/db/senai.d/locks/screensaver > /dev/null <<'LOCKSEOF'
/org/gnome/desktop/screensaver/lock-enabled
LOCKSEOF

sudo mkdir -p /etc/dconf/profile
sudo tee /etc/dconf/profile/aluno > /dev/null <<'PROFILEEOF'
user-db:user
system-db:senai
PROFILEEOF

sudo mkdir -p "$ALUNO_HOME/.config/environment.d"
sudo tee "$ALUNO_HOME/.config/environment.d/dconf.conf" > /dev/null <<'ENVEOF'
DCONF_PROFILE=aluno
ENVEOF

sudo dconf update

# ─── Autologin ────────────────────────────────────────────────────────────────

LOG "2026052610 - Configurando autologin para $ALUNO_USERNAME"

if systemctl is-active --quiet gdm3 2>/dev/null || systemctl is-active --quiet gdm 2>/dev/null \
	|| [ -f /etc/gdm3/custom.conf ]; then
	# Zorin OS Core (GDM3 + GNOME)
	sudo tee /etc/gdm3/custom.conf > /dev/null <<GDMEOF
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=aluno
TimedLoginEnable=false

[security]

[xdmcp]

[chooser]

[debug]
GDMEOF
	LOG "Autologin configurado via GDM3."

elif [ -f /etc/lightdm/lightdm.conf ] || systemctl is-active --quiet lightdm 2>/dev/null; then
	# Zorin OS Lite (LightDM + XFCE)
	sudo tee /etc/lightdm/lightdm.conf > /dev/null <<'LDMEOF'
[Seat:*]
autologin-user=aluno
autologin-user-timeout=0
LDMEOF
	LOG "Autologin configurado via LightDM."

else
	LOG "AVISO: Display Manager nao identificado. Configure o autologin manualmente."
fi

# ─── Configuracoes da Area de Trabalho do Aluno ───────────────────────────────
#
#  Aplicadas via autostart a cada login. Garante o padrao mesmo que o usuario
#  tente alterar itens nao cobertos pelos locks do dconf.

LOG "2026052611 - Configurando area de trabalho padrao do $ALUNO_USERNAME"

AUTOSTART_DIR="$ALUNO_HOME/.config/autostart"
sudo mkdir -p "$AUTOSTART_DIR"

sudo tee "$AUTOSTART_DIR/senai-desktop-setup.sh" > /dev/null <<'SETUPEOF'
#!/bin/bash
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
gsettings set org.gnome.shell favorite-apps \
	"['firefox.desktop', 'google-chrome.desktop', 'onlyoffice-desktopeditors_onlyoffice-desktopeditors.desktop', 'org.gnome.Nautilus.desktop']"
SETUPEOF
sudo chmod +x "$AUTOSTART_DIR/senai-desktop-setup.sh"

sudo tee "$AUTOSTART_DIR/senai-desktop-setup.desktop" > /dev/null <<DESKTOPEOF
[Desktop Entry]
Type=Application
Name=SENAI Desktop Setup
Exec=$ALUNO_HOME/.config/autostart/senai-desktop-setup.sh
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
DESKTOPEOF

sudo chown -R "$ALUNO_USERNAME:$ALUNO_USERNAME" "$ALUNO_HOME/.config"

# ─── SSH - acesso remoto ─ Firewall ───────────────────────────────────────────
# Instalação do Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
# Login na rede da ACI - Essa Key só vale até 27/08/2026
sudo tailscale up --authkey=tskey-auth-kjYSkZHvM221CNTRL-UU65WwkLKncsZEVMdfsjnc1yh1YZxJ5H
# Subir Serviço de SSH
sudo systemctl start ssh
sudo systemctl enable ssh
# Subir firewall
sudo ufw allow from 10.0.0.0/8 to any port 22 proto tcp
sudo ufw allow from 172.16.0.0/12 to any port 22 proto tcp
sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp
sudo ufw allow from 100.64.0.0/10 to any port 22 proto tcp # todo o intervalo do tailscale
sudo ufw enable

# ─── Conclusao ────────────────────────────────────────────────────────────────

LOG "2026052612 - Script concluido."

echo "
============================================================
  Instalacao concluida com sucesso!

  PROXIMOS PASSOS:
    1. Reinicie o sistema: sudo reboot
    2. O boot iniciara automaticamente com o usuario 'aluno'.
    3. Para acessar como administrador, use Trocar Usuario no menu.

============================================================
"
