# CodingWorkstation_Windows11_winget.ps1
# Instalação via winget com escopo de máquina

# Elevar para Admin, se necessário
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "Elevando para Administrador..."
  $args = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
  Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $args
  exit
}

# Conferir winget e atualizar fontes
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget não encontrado. Abra a Microsoft Store e instale o 'App Installer' da Microsoft."
  exit 1
}
winget source update --accept-source-agreements | Out-Null

# Credencial de rede
$target = "\\mdcserver"
$cred = Get-Credential -Message "Informe usuário e senha da rede $target"
cmdkey /add:$target /user:$($cred.UserName) /pass:$($cred.GetNetworkCredential().Password)
Write-Host "Credencial adicionada para $target"

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


Write-Host "`nConcluído."
