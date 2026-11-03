@echo off
REM Tunnel SSH vers le VPS pour exposer /metrics/prom du connecteur sur localhost:8001
REM Usage: set VPS_HOST=vps-xxxx.vps.ovh.net & set SSH_KEY=%USERPROFILE%\.ssh\ma_cle & tunnel-ssh.bat [MCP_API_KEY]
REM (hôte et clé en variables d'env : rien de sensible en dur dans ce dépôt public)

set KEY=%MCP_API_KEY%
if "%~1" neq "" set KEY=%~1
if "%KEY%"=="" (
  echo ERREUR: définis MCP_API_KEY dans l'env ou passe-la en argument
  exit /b 1
)
if "%VPS_HOST%"=="" (
  echo ERREUR: définis VPS_HOST (ex: vps-xxxx.vps.ovh.net)
  exit /b 1
)
if "%SSH_KEY%"=="" set SSH_KEY=%USERPROFILE%\.ssh\id_rsa

echo Ouverture du tunnel SSH: localhost:8001 -^> %VPS_HOST%:8001
echo (laisse cette fenetre ouverte)
ssh -i "%SSH_KEY%" -N -L 8001:localhost:8001 "root@%VPS_HOST%"
