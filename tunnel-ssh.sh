#!/usr/bin/env bash
# Tunnel SSH vers le VPS pour exposer /metrics/prom du connecteur sur localhost:8001
# Usage: VPS_HOST=vps-xxxx.vps.ovh.net SSH_KEY=~/.ssh/ma_cle ./tunnel-ssh.sh [MCP_API_KEY]
# (hôte et clé en variables d'env : rien de sensible en dur dans ce dépôt public)

KEY="${MCP_API_KEY:-$1}"
HOST="${VPS_HOST:?définir VPS_HOST (ex: vps-xxxx.vps.ovh.net)}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"

if [ -z "$KEY" ]; then
  echo "ERREUR: définis MCP_API_KEY dans l'env ou passe-la en argument"
  exit 1
fi

echo "Ouverture du tunnel SSH: localhost:8001 -> ${HOST}:8001"
echo "(laisse ce terminal ouvert)"
ssh -i "$SSH_KEY" -N -L 8001:localhost:8001 "root@${HOST}"
