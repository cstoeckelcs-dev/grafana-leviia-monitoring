# Grafana Leviia MCP — Monitoring local via tunnel SSH

Projet local pour afficher un dashboard Grafana des métriques du connecteur
Leviia MCP (`LEVIICHOST.example`), **sans ouvrir de route nginx publique** :
le VPS reste fermé, on passe par un tunnel SSH.

## Architecture

```
Ton PC (Windows)
  ├── tunnel SSH: localhost:8001 → ${VPS_HOST}:8001   (tunnel-ssh.bat)
  ├── Prometheus :9090  scrape http://host.docker.internal:8001/metrics/prom
  └── Grafana    :3000  lit Prometheus → dashboard "Leviia MCP — Supervision"
                         │
                         ▼ (tunnel SSH)
                   VPS: leviia-mcp:8001/metrics/prom  (Bearer MCP_API_KEY)
```

## Prérequis

- Docker Desktop installé et lancé
- La clé `MCP_API_KEY` du connecteur (dans le `.env` du VPS : `/opt/apps/leviia-mcp/.env (non versionné)`)
- La clé SSH `~/.ssh/TA_CLE_SSH`

## Démarrage (3 étapes)

### 1. Ouvrir le tunnel SSH (fenêtre 1)

```bat
:: Windows
set MCP_API_KEY=ta_cle_mcp
tunnel-ssh.bat
```

```bash
# Linux/Mac
export MCP_API_KEY=ta_cle_mcp
./tunnel-ssh.sh
```

Vérifier : `curl -H "Authorization: Bearer %MCP_API_KEY%" http://localhost:8001/metrics/prom`

### 2. Remplacer la clé dans Prometheus

Éditer `prometheus/prometheus.yml` :
```yaml
    authorization:
      type: Bearer
      credentials: "TA_CLE_MCP_API_KEY"
```

### 3. Lancer Grafana + Prometheus (fenêtre 2)

```bash
docker compose up -d
```

- Grafana : http://localhost:3000 (admin / $GRAFANA_ADMIN_PASSWORD)
- Prometheus : http://localhost:9090 (vérifier que la target `leviia-mcp` est UP)
- Dashboard : **Leviia MCP — Supervision** (provisionné automatiquement)

## Métriques disponibles

| Métrique | Description |
|----------|-------------|
| `leviia_mcp_calls_total` | appels MCP sur 1 jour |
| `leviia_tool_calls_total{tool}` | appels par outil |
| `leviia_tool_p95_ms{tool}` | latence p95 par outil |
| `leviia_tool_error_rate{tool}` | taux d'erreur % par outil |
| `leviia_tool_credits{tool}` | crédits consommés par outil |
| `leviia_credits_total` | crédits totaux |
| `leviia_credits_by_category{category}` | crédits par catégorie (recherche vs indexation) |
| `leviia_feedback_total{severity}` | feedbacks utilisateurs |

## Sécurité

- Aucune route nginx ouverte : `/metrics/prom` retourne 404 depuis l'extérieur
- Le endpoint exige le Bearer `MCP_API_KEY` même en interne (défense en profondeur)
- Le tunnel SSH chiffre tout le trafic
