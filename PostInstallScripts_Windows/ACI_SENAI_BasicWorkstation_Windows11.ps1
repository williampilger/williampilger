# Computadores do SENAI
# Instalação via winget com escopo de máquina
#
## Execute diretamente usando (PowerShell como Administrador):
## irm https://raw.githubusercontent.com/williampilger/williampilger/main/PostInstallScripts_Windows/ACI_SENAI_BasicWorkstation_Windows11.ps1 | iex


# ─── Pré-requisitos ─────────────────────────────────────────────────────────


# Garante winget atualizado
Write-Host "Atualizando winget..."
$url = "https://aka.ms/getwinget"
$out = "$env:TEMP\AppInstaller.msixbundle"
Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
Add-AppxPackage -Path $out -ErrorAction SilentlyContinue

# Aguarda winget ficar disponível
$tries = 0
while (-not (Get-Command winget -ErrorAction SilentlyContinue) -and $tries -lt 10) {
    Start-Sleep -Seconds 3
    $tries++
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget não encontrado mesmo após instalação. Abra a Microsoft Store e instale o 'App Installer'."
    exit 1
}

# Aceita os termos do winget (necessário em instalações limpas)
winget list --accept-source-agreements | Out-Null

# Atualiza as fontes
winget source update --accept-source-agreements | Out-Null

Write-Host "winget pronto: $(winget --version)"


# ─── Instalação dos pacotes ─────────────────────────────────────────────────────


# Elevar para Admin, se necessário
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "Elevando para Administrador..."
  $args = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
  Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $args
  exit
}

# atualizar fontes do winget
winget source update --accept-source-agreements | Out-Null

# Instalar pacotes
winget install --id Google.Chrome --source winget --scope machine --accept-package-agreements --accept-source-agreements --silent
winget install --id 7zip.7zip --source winget --scope machine --accept-package-agreements --accept-source-agreements --silent
winget install --id Mozilla.Firefox --source winget --scope machine --accept-package-agreements --accept-source-agreements --silent
winget install --id ONLYOFFICE.DesktopEditors --source winget --scope machine --accept-package-agreements --accept-source-agreements --silent
winget install --id Tailscale.Tailscale --source winget --scope machine --accept-package-agreements --accept-source-agreements --silent


# ─── Acesso ACI Externo ─────────────────────────────────────────────────────


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
# Remove o ícone da bandeja do Tailscale
& "C:\Program Files\Tailscale\tailscale.exe" set --unattended
Get-Process tailscale-ipn -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" `
    -Name "Tailscale" `
    -ErrorAction SilentlyContinue


# ─── Criação do usuário ─────────────────────────────────────────────────────


# Usuário Aluno
if (-not (Get-LocalUser -Name "Aluno" -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name "Aluno" -NoPassword -FullName "Aluno" -UserMayNotChangePassword
    Add-LocalGroupMember -SID "S-1-5-32-545" -Member "Aluno"
}
# Bloqueia login e adição de contas Microsoft para todos os usuários
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
  -Name "NoConnectedUser" -Value 3 -Type DWord -Force



# ─── Interface do usuário ─────────────────────────────────────────────────────

# Políticas de máquina (todos os usuários, aplicadas sem login)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
  -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" `
  -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

# Hive do perfil padrão — herdado pelo Aluno (e qualquer novo usuário) na primeira entrada
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"

$advKey = "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
reg add $advKey /v "TaskbarAl"         /t REG_DWORD /d 0 /f | Out-Null  # ícones à esquerda
reg add $advKey /v "TaskbarDa"         /t REG_DWORD /d 0 /f | Out-Null  # ocultar Widgets
reg add $advKey /v "ShowCopilotButton" /t REG_DWORD /d 0 /f | Out-Null  # ocultar Copilot
reg add $advKey /v "LaunchTo"          /t REG_DWORD /d 1 /f | Out-Null  # Explorer → Este Computador

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" `
  /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f | Out-Null             # ocultar Pesquisa

$deskKey = "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
reg add $deskKey /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f | Out-Null  # Este Computador
reg add $deskKey /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f | Out-Null  # Lixeira

[GC]::Collect()
reg unload "HKU\DefaultUser"

# Atalhos na área de trabalho pública (visíveis para todos os usuários)
$pubDesktop = "C:\Users\Public\Desktop"
$startMenu  = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
@("Google Chrome.lnk", "Mozilla Firefox.lnk", "ONLYOFFICE Desktop Editors.lnk") | ForEach-Object {
    $src = Join-Path $startMenu $_
    if (Test-Path $src) { Copy-Item $src $pubDesktop -Force }
}


# ─── Remover OneDrive definitivamente ─────────────────────────────────────────


Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue

winget uninstall --id Microsoft.OneDrive --silent --accept-source-agreements

# Limpar pastas residuais
@(
  "$env:USERPROFILE\OneDrive",
  "$env:LOCALAPPDATA\Microsoft\OneDrive",
  "$env:PROGRAMDATA\Microsoft OneDrive",
  "$env:SYSTEMDRIVE\OneDriveTemp"
) | ForEach-Object { Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue }

# Remover do painel lateral do Explorer
reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f | Out-Null
reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f | Out-Null

# Bloquear reinstalação automática via política
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" `
  -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force

# Impedir que novos usuários recebam OneDrive no startup
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
reg delete "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f | Out-Null
[GC]::Collect()
reg unload "HKU\DefaultUser"


# ─── Finalização ─────────────────────────────────────────────────────


# Upgrade final de tudo no escopo de máquina
winget upgrade --all --include-unknown --scope machine --accept-package-agreements --accept-source-agreements --silent --disable-interactivity

Write-Host "`nConcluído."
