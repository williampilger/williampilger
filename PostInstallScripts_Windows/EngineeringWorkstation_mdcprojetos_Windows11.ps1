# CodingWorkstation_Windows11_winget.ps1
# Instalação via winget com escopo de máquina
#
# Execute direto no Executar com:
#  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/williampilger/williampilger/refs/heads/main/PostInstallScripts_Windows/EngineeringWorkstation_mdcprojetos_Windows11.ps1').Content"
#
# Versão Atualizada em 2025-09-02 11:17:15

# Elevar para Admin, se necessário
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "Elevando para Administrador..."
  $args = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
  Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $args
  exit
}

# Credencial de rede
$target = "\\mdcserver"
$cred = Get-Credential -Message "Informe usuário e senha da rede $target"
cmdkey /add:$target /user:$($cred.UserName) /pass:$($cred.GetNetworkCredential().Password)
Write-Host "Credencial adicionada para $target"

# Conferir winget e atualizar fontes
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget não encontrado. Abra a Microsoft Store e instale o 'App Installer' da Microsoft."
  exit 1
}
winget source update --accept-source-agreements | Out-Null

# Acesso SSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Start-Service sshd
powershell -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force"

# Instalação via winget
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
$packages = @(
  # Base
  @{ Id = 'Microsoft.PowerShell' }
  @{ Id = '7zip.7zip' }
  @{ Id = 'Python.Python.3' }
  @{ Id = 'Google.Chrome' }
  @{ Id = 'Mozilla.Firefox' }
  @{ Id = 'Microsoft.PowerToys' }
  @{ Id = 'Adobe.Acrobat.Reader.64-bit' }
  @{ Id = 'CodecGuide.K-LiteCodecPack.Mega' }
  @{ Id = 'VideoLAN.VLC' }
  @{ Id = 'uvncbvba.UltraVNC' }
  @{ Id = 'OBSProject.OBSStudio' }
  @{ Id = 'Oracle.JavaRuntimeEnvironment' }
  @{ Id = 'ONLYOFFICE.DesktopEditors' }
  
)
foreach ($p in $packages) {
  try {
    Install-Winget -Id $p.Id -Source ($p.Source) -Override ($p.Override)
  } catch {
    Write-Warning "Falhou: $($p.Id) Detalhe: $($_.Exception.Message)"
  }
}
winget upgrade --all --include-unknown --scope machine --accept-package-agreements --accept-source-agreements --silent --disable-interactivity


# Script de limpeza deStartup (padrão MDC)
$Url = "https://raw.githubusercontent.com/williampilger/utilidades_gerais/master/authenty_diversos/startup_script/clear_temp.pyw"
$ScriptFolder = "C:\scripts"
New-Item -Path $ScriptFolder -ItemType Directory -Force | Out-Null
$ScriptPath = Join-Path $ScriptFolder "clear_temp.pyw"
$StartupGlobal = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
$ShortcutPath = Join-Path $StartupGlobal "ClearTemp.lnk"
$Pythonw = @(
  "C:\Program Files\Python313\pythonw.exe",
  "C:\Program Files\Python312\pythonw.exe",
  "C:\Program Files\Python311\pythonw.exe",
  "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python312\pythonw.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
Invoke-WebRequest -Uri $Url -OutFile $ScriptPath
Unblock-File -Path $ScriptPath
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $Pythonw
$Shortcut.Arguments = "`"$ScriptPath`""
$Shortcut.WorkingDirectory = $ScriptFolder
$Shortcut.Description = "Executa clear_temp.pyw no logon (todos os usuários)"
$Shortcut.WindowStyle = 7
$Shortcut.Save()

Write-Host "`nConcluído."
