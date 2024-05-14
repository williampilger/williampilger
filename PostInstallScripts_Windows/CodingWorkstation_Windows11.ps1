# ESTE SCRIPT DÁ MUITA MÃO PARA EXECUTAR.
# Use o .bat se for possível. (INCLUSIVE, ESTE PODE ESTAR DESATUALIZADO)

# Função para instalar pacotes via Chocolatey
function Install-ChocoPackage {
    param (
        [string]$packageName
    )
    Write-Host "Instalando $packageName"
    choco install $packageName -y
}

# Define a lista de pacotes para instalação
$packages = @(
    'git',
    'nodejs-lts',
    'vscode',
    'docker-desktop',
    'python',
    'wget',
    'curl',
    'googlechrome'
)

# Loop para instalar cada pacote
foreach ($package in $packages) {
    Install-ChocoPackage -packageName $package
}

Write-Host "Todos os pacotes foram instalados com sucesso."
