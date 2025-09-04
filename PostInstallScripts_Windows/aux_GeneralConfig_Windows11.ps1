# Requer: Windows 11. Execute preferencialmente como Administrador.
#
# ⚠️ Criado pelo ChatGPT e não revisado! Não está funcionando completamente.
# ESTE É UM SCRIPT COMPLEMENTAR!!!
# 
# Execute diretamente (no CMD ou powershell COMO ADMIN) com o comando abaixo:
#   powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/williampilger/williampilger/refs/heads/main/PostInstallScripts_Windows/aux_GeneralConfig_Windows11.ps1').Content"

# ========== Helpers ==========
function Test-Admin {
  $wi = [Security.Principal.WindowsIdentity]::GetCurrent()
  (New-Object Security.Principal.WindowsPrincipal $wi).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
$IsAdmin = Test-Admin

function Set-REG([string]$Path, [string]$Name, [Object]$Value, [string]$Type="DWord") {
  New-Item -Path $Path -Force | Out-Null
  New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force | Out-Null
}

# ========== 1) Desfixar tudo da barra de tarefas, exceto o Explorer ==========
try {
  $PinnedDir = Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
  New-Item -ItemType Directory -Path $PinnedDir -Force | Out-Null

  # Cria atalho do Explorer, garantindo que exista
  $ExplorerLnk = Join-Path $PinnedDir "File Explorer.lnk"
  if (-not (Test-Path $ExplorerLnk)) {
    $ws = New-Object -ComObject WScript.Shell
    $sc = $ws.CreateShortcut($ExplorerLnk)
    $sc.TargetPath  = "$env:WINDIR\explorer.exe"
    $sc.IconLocation = "$env:WINDIR\explorer.exe,0"
    $sc.Save()
  }

  # Remove todos os .lnk que NÃO apontem para explorer.exe
  Get-ChildItem -Path $PinnedDir -Filter *.lnk -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      $ws = New-Object -ComObject WScript.Shell
      $t = $ws.CreateShortcut($_.FullName).TargetPath
      if (-not $t) { Remove-Item $_.FullName -Force; return }
      if (-not ($t -ieq "$env:WINDIR\explorer.exe")) { Remove-Item $_.FullName -Force }
    } catch { Remove-Item $_.FullName -Force }
  }

  # Limpa cache de pins para forçar atualização, preservando o .lnk do Explorer criado acima
  Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Recurse -ErrorAction SilentlyContinue
} catch {}

# ========== 2) Menu Iniciar à esquerda ==========
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" 0

# ========== 3) Ocultar Pesquisa na barra de tarefas ==========
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SearchboxTaskbarMode" 0

# ========== 4) Remover Widgets e Visão de Tarefas ==========
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0      # Widgets
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0  # Visão de Tarefas
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 0     # Chat/Teams
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" 0   # Botão Copilot

# ========== 5) Tema escuro (Apps e Sistema) ==========
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" 0
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" 0

# ========== 6) Chrome como padrão (melhor esforço, sem GUI) ===
$ChromePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $ChromePath)) {
  $ChromePath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
}

if (Test-Path $ChromePath) {
  # 1) Associa as extensões a um ProgID "ChromeHTML"
  cmd.exe /c 'assoc .htm=ChromeHTML'  | Out-Null
  cmd.exe /c 'assoc .html=ChromeHTML' | Out-Null

  # 2) Define o comando de abertura do ProgID
  $openCmd  = ('"{0}" -- "%1"' -f $ChromePath)
  $ftypeCmd = ('ftype ChromeHTML={0}' -f $openCmd)
  cmd.exe /c $ftypeCmd | Out-Null

  # 3) Tenta pedir ao Chrome para se tornar o padrão (pode não surtir efeito sem GUI)
  Start-Process -FilePath $ChromePath -ArgumentList '--make-default-browser' -WindowStyle Hidden -ErrorAction SilentlyContinue
}

# ========== 7) Explorer abre em “Este Computador” e mostrar extensões ==========
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1     # 1 = Este Computador, 2 = Acesso Rápido
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0  # Mostrar extensões

# ========== 8) Remover sugestões e recentes do Acesso Rápido e limpar histórico ==========
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowRecent" 0
Set-REG "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowFrequent" 0
$AutoDest = Join-Path $env:APPDATA "Microsoft\Windows\Recent\AutomaticDestinations"
$CustDest = Join-Path $env:APPDATA "Microsoft\Windows\Recent\CustomDestinations"
Get-ChildItem $AutoDest -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem $CustDest -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# ========== 9) Desinstalar Microsoft Copilot ==========
if ($IsAdmin) {
  # Desabilita por política
  Set-REG "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
  # Remove Appx se existir
  Get-AppxPackage -AllUsers *Microsoft.Copilot* -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
  Get-AppxPackage -AllUsers *Copilot* -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

# ========== 10) Desinstalar OneDrive ==========
if ($IsAdmin) {
  try { taskkill /f /im OneDrive.exe | Out-Null } catch {}
  $od64 = "$env:SystemRoot\System32\OneDriveSetup.exe"
  $od32 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
  $od   = if (Test-Path $od32) { $od32 } elseif (Test-Path $od64) { $od64 } else { $null }
  if ($od) { Start-Process -FilePath $od -ArgumentList "/uninstall" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue }
  # Limpa pastas conhecidas
  Remove-Item "$env:UserProfile\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item "$env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
  # Remove do painel do Explorer e evita reinstalação
  Set-REG "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSync" 1
  Set-REG "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
  Set-REG "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
}

# ========== Aplicar mudanças do Explorer ==========
try {
  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
  Start-Process explorer.exe -ErrorAction SilentlyContinue
} catch {}

# Saída amigável
Write-Host "Concluído. Algumas mudanças podem exigir logoff."
if (-not $IsAdmin) {
  Write-Host "Observação: partes que exigem Administrador foram ignoradas. Execute como Admin para desinstalar OneDrive e aplicar políticas do Copilot."
}
