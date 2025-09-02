# CodingWorkstation_Windows11_winget.ps1
# Instalação via winget com escopo de máquina
#
# Execute direto (no terminal, COMO ADMIN) com:
#  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/williampilger/williampilger/refs/heads/main/PostInstallScripts_Windows/EngineeringWorkstation_mdcprojetos_Windows11.ps1').Content"
#
# Versão Atualizada em 2025-09-02 16:50:49

# Credencial de rede
$target = "\\mdcserver"
$cred = Get-Credential -Message "Informe usuário e senha da rede $target"
cmdkey /add:$target /user:$($cred.UserName) /pass:$($cred.GetNetworkCredential().Password)
Write-Host "Credencial adicionada para $target"

# Acesso SSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Start-Service sshd
powershell -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force"

# Conferir winget e atualizar fontes
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget não encontrado. Abra a Microsoft Store e instale o 'App Installer' da Microsoft."
  exit 1
}
winget source update --accept-source-agreements | Out-Null

# Instalando os softwares (não criei um loop e uma função por que não funciona direito >>> windows! kkk )
$packages = @(
  "7zip.7zip",
  "Google.Chrome",
  "Mozilla.Firefox",
  "Microsoft.PowerToys",
  "Adobe.Acrobat.Reader.64-bit",
  "CodecGuide.K-LiteCodecPack.Mega",
  "VideoLAN.VLC",
  "OBSProject.OBSStudio",
  "Oracle.JavaRuntimeEnvironment",
  "ONLYOFFICE.DesktopEditors",
  "Python.Python.3",
  "uvncbvba.UltraVNC"
)
foreach ($package in $packages) {
  Write-Host "Instalando $package..."
  winget install --scope machine $package --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
}

# Atualizar apps winget
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
