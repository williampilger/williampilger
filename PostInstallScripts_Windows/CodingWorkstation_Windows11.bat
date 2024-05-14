@echo off
SETLOCAL EnableDelayedExpansion

CALL :AdminCheck
choco upgrade chocolatey

choco install -y git
choco install -y wget
choco install -y curl
choco install -y nodejs-lts
choco install -y vscode
choco install -y docker-desktop
choco install -y python
choco install -y spotify
choco install -y powertoys

:: Configuração do Python
pip install --upgrade pip
pip install virtualenv

:: Configuração do Node.js
npm install -g npm@latest
powershell -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned"

:: Baixar e instalar Google Chrome
powershell -Command "Invoke-WebRequest 'https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B806F36C0-CB54-4B1A-9F2C-5034BD9BD5E7%7D%26lang%3Dpt%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%20Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26brand%3DGCEA/dl/chrome/install/googlechromestandaloneenterprise64.msi' -OutFile 'chrome_installer.msi'"
msiexec /i chrome_installer.msi /qn

:: Baixar e instalar WhatsApp Desktop
powershell -Command "Invoke-WebRequest 'https://web.whatsapp.com/desktop/windows/release/x64/WhatsAppSetup.exe' -OutFile 'WhatsAppSetup.exe'"
start /wait WhatsAppSetup.exe /S


echo Processo Finalizado.
pause
exit /B


:: Função para checar se está rodando como Administrador
:AdminCheck
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO Executando como Administrador.
    GOTO :eof
) ELSE (
    ECHO.
    ECHO Por favor, rode este script como Administrador.
    ECHO.
    PAUSE
    EXIT
)
