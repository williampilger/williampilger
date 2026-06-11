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
& "C:\Program Files\Tailscale\tailscale.exe" up `
  --authkey=tskey-auth-kjYSkZHvM221CNTRL-UU65WwkLKncsZEVMdfsjnc1yh1YZxJ5H `
  --unattended=true
# Firewall pro Tailscale
New-NetFirewallRule -Name "OpenSSH-Server-In-TCP-Tailscale" -DisplayName "OpenSSH Server (TCP 22) - Tailscale" `
  -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -RemoteAddress "100.64.0.0/10"
# Garante que o serviço continue automático
Set-Service Tailscale -StartupType Automatic
Start-Service Tailscale
# Remove/fecha apenas a interface gráfica da bandeja
Get-Process tailscale-ipn -ErrorAction SilentlyContinue | Stop-Process -Force
# Remove inicialização automática da interface gráfica
Remove-ItemProperty `
  -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" `
  -Name "Tailscale" `
  -ErrorAction SilentlyContinue
Remove-ItemProperty `
  -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" `
  -Name "Tailscale" `
  -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Tailscale.lnk" `
  -Force `
  -ErrorAction SilentlyContinue
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\Tailscale.lnk" `
  -Force `
  -ErrorAction SilentlyContinue
  


# ─── Ajustes das políticas de segurança do windows ─────────────────────────────────────────────────────



# Permite login sem senha (senha em branco)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
  -Name "LimitBlankPasswordUse" -Value 0 -Type DWord -Force
  
# Bloqueia login e adição de contas Microsoft para todos os usuários
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
  -Name "NoConnectedUser" -Value 3 -Type DWord -Force

# Política de máquina — desabilita Windows Hello
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" `
  -Name "Enabled" -Value 0 -Type DWord -Force

# Bloquear acesso ao painel de controle (herdado pelo Aluno)
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
  /v "NoControlPanel" /t REG_DWORD /d 1 /f | Out-Null
[GC]::Collect()
reg unload "HKU\DefaultUser"


# ─── Criação do usuário ─────────────────────────────────────────────────────


# Usuário Aluno
if (-not (Get-LocalUser -Name "Aluno" -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name "Aluno" -NoPassword -FullName "Aluno" -UserMayNotChangePassword
    Add-LocalGroupMember -SID "S-1-5-32-545" -Member "Aluno"
}
Set-LocalUser -Name "Aluno" -PasswordNeverExpires $true



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
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /t REG_DWORD /d 0 /f       # Ocultar Chat
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f | Out-Null             # ocultar Pesquisa

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

# Definindo Taskbar padrão (Explorer e Google Chrome)
$xmlPath = "C:\Windows\TaskbarLayout.xml"
@'
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
  xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
  xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
  xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
  Version="1">

  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="%ProgramData%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
'@ | Set-Content -Path $xmlPath -Encoding UTF8
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v StartLayoutFile /t REG_SZ /d $xmlPath /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v LockedStartLayout /t REG_DWORD /d 1 /f



# ─── Remover apps da Microsoft ─────────────────────────────────────────


$apps = @(
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.Xbox.TCUI",
    "Microsoft.GamingApp",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.BingNews",
    "Microsoft.People",
    "Microsoft.Todos",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.SkypeApp",
    "Microsoft.549981C3F5F10",
    "Clipchamp.Clipchamp",
    "Microsoft.OutlookForWindows",
    "MSTeams"
)
foreach ($app in $apps) {

    Get-AppxPackage -AllUsers -Name $app |
        Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    Get-AppxProvisionedPackage -Online |
        Where-Object DisplayName -eq $app |
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}


# ─── Remover OneDrive definitivamente ─────────────────────────────────────────



# Bloquear OneDrive por política para todos os usuários
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" `
  -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force

# Desativar sugestões de backup/sync no Explorer para todos os usuários novos
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
  /v "ShowSyncProviderNotifications" /t REG_DWORD /d 0 /f | Out-Null

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
  /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f | Out-Null

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
  /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f | Out-Null

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
  /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f | Out-Null

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
  /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f | Out-Null

reg delete "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Run" `
  /v "OneDrive" /f 2>$null

[GC]::Collect()
reg unload "HKU\DefaultUser"

# Aplicar também ao usuário atual/Admin
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
  /v "ShowSyncProviderNotifications" /t REG_DWORD /d 0 /f | Out-Null

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
  /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f | Out-Null

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
  /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f | Out-Null

# Parar OneDrive
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue

# Desinstalar pelo instalador nativo do Windows
$oneDriveSetups = @(
  "$env:SystemRoot\System32\OneDriveSetup.exe",
  "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
)

foreach ($setup in $oneDriveSetups) {
  if (Test-Path $setup) {
    Start-Process -FilePath $setup -ArgumentList "/uninstall" -Wait -WindowStyle Hidden
  }
}

# Desinstalar via winget, se existir
winget uninstall --id Microsoft.OneDrive --silent --accept-source-agreements --disable-interactivity `
  2>$null

# Remover provisionamento, se existir como Appx
Get-AppxProvisionedPackage -Online |
  Where-Object { $_.DisplayName -like "*OneDrive*" } |
  Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

Get-AppxPackage -AllUsers |
  Where-Object { $_.Name -like "*OneDrive*" } |
  Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

# Remover inicialização para todos os usuários carregados
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 2>$null
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 2>$null
reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 2>$null

# Remover do painel lateral do Explorer
reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null
reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null

# Limpar pastas residuais principais
@(
  "$env:USERPROFILE\OneDrive",
  "$env:LOCALAPPDATA\Microsoft\OneDrive",
  "$env:PROGRAMDATA\Microsoft OneDrive",
  "$env:SYSTEMDRIVE\OneDriveTemp"
) | ForEach-Object {
  Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue
}



# ─── Energia ─────────────────────────────────────────────────────



# Nunca desligar o monitor — política de máquina (todos os usuários)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" `
  -Name "ACSettingIndex" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" `
  -Name "DCSettingIndex" -Value 0 -Type DWord -Force

# Nunca suspender — política de máquina (todos os usuários)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20" `
  -Name "ACSettingIndex" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20" `
  -Name "DCSettingIndex" -Value 0 -Type DWord -Force



# ─── Atualização e Ponto de Restauração ─────────────────────────────────────────────


# Upgrade final de tudo no escopo de máquina
winget upgrade --all --include-unknown --scope machine --accept-package-agreements --accept-source-agreements --silent --disable-interactivity

# A Proteção do Sistema vem DESABILITADA por padrão no Win11 — precisa ligar antes
Enable-ComputerRestore -Drive "C:\"

# Remove o limite de 1 ponto a cada 24h (senão chamadas repetidas são ignoradas sem erro)
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" `
  -Name "SystemRestorePointCreationFrequency" -Value 0 -Type DWord -Force

# Cria o ponto
Checkpoint-Computer -Description "SENAI - Pos-instalacao concluida" -RestorePointType "MODIFY_SETTINGS"

# Para criar um pós finalizar a configuração, ou no momento da instalação
#Checkpoint-Computer -Description "SENAI - Finalizado para Utilização" -RestorePointType "MODIFY_SETTINGS"


# ─── Finalização ─────────────────────────────────────────────────────



Write-Host "`nConcluído."
$resposta = Read-Host "Deseja reiniciar agora? (S/N)"
if ($resposta -match "^[Ss]$") {
    Restart-Computer -Force
} else {
    Write-Host "Reinicie manualmente para aplicar todas as configurações."
}
