# Computadores do SENAI
# Instalação via winget com escopo de máquina
#
## Execute diretamente usando (PowerShell como Administrador):
## irm https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_Windows/ACI_SENAI_BasicWorkstation_Windows11.ps1 | iex

# --------------------------------------------------------------------------
# CONFIGURAÇÕES
$packages = @(
  # Essenciais
  @{ Id = 'Microsoft.PowerShell' }
  @{ Id = '7zip.7zip' }
  @{ Id = 'Google.Chrome' }
  @{ Id = 'Mozilla.Firefox' }
  @{ Id = 'ONLYOFFICE.DesktopEditors' }
  @{ Id = 'Tailscale.Tailscale' }
)
# --------------------------------------------------------------------------


# Elevar para Admin, se necessário
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "Elevando para Administrador..."
  $args = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
  Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $args
  exit
}

# Conferir winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget não encontrado. Abra a Microsoft Store e instale o 'App Installer' da Microsoft."
  exit 1
}

# Atualizar fontes do winget
winget source update --accept-source-agreements | Out-Null

# Wrapper para instalar com padrão de máquina
function Install-Winget {
  param(
    [Parameter(Mandatory=$true)][string]$Id,
    [string]$Source = "winget",
    [string]$Override = $null
  )
  $base = @(
    'install',
    '--id', $Id,
    '--source', $Source,
    '--scope', 'machine',
    '--accept-package-agreements',
    '--accept-source-agreements',
    '--disable-interactivity',
    '--silent',
    '--force' # força upgrade se já existir
  )
  if ($Override) { $base += @('--override', $Override) }
  winget @base
}

# Instalar toda a lista de softwares
foreach ($p in $packages) {
  try {
    Install-Winget -Id $p.Id -Source ($p.Source) -Override ($p.Override)
  } catch {
    Write-Warning "Falhou: $($p.Id) Detalhe: $($_.Exception.Message)"
  }
}

# Acesso SSH e Firewall
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Start-Service sshd
New-NetFirewallRule -Name "OpenSSH-Server-In-TCP-LocalSubnet" -DisplayName "OpenSSH Server (TCP 22) - LocalSubnet" `
  -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -RemoteAddress LocalSubnet

# Tailscale - Login na rede da ACI (Key válida até 27/08/2026)
& "C:\Program Files\Tailscale\tailscale.exe" up --authkey=tskey-auth-kjYSkZHvM221CNTRL-UU65WwkLKncsZEVMdfsjnc1yh1YZxJ5H
New-NetFirewallRule -Name "OpenSSH-Server-In-TCP-Tailscale" -DisplayName "OpenSSH Server (TCP 22) - Tailscale" `
  -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -RemoteAddress "100.64.0.0/10"




# Usuário Aluno
if (-not (Get-LocalUser -Name "Aluno" -ErrorAction SilentlyContinue)) {
  New-LocalUser -Name "Aluno" -NoPassword -FullName "Aluno" `
    -PasswordNeverExpires -UserMayNotChangePassword
  # Adiciona ao grupo Usuários padrão (SID fixo, independe do idioma do Windows)
  Add-LocalGroupMember -SID "S-1-5-32-545" -Member "Aluno"
}
# Bloqueia login e adição de contas Microsoft para todos os usuários
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
  -Name "NoConnectedUser" -Value 3 -Type DWord -Force


# Upgrade final de tudo no escopo de máquina
winget upgrade --all --include-unknown --scope machine --accept-package-agreements --accept-source-agreements --silent --disable-interactivity



Write-Host "`nConcluído."
