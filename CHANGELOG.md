# Changelog — pedaree-infra-devops

Format mengikuti Keep a Changelog; versi mengikuti TownHall.

## [Belum dirilis]

### Ditambahkan
- Fondasi AI-dev v1.0.0: `AGENTS.md`, `CLAUDE.md`, ADR-0001, `docs/ARSITEKTUR-AI-DEV.md` (2026-10-14).
- Secrets per env (`.env.example`, `secrets/pedaree-secrets.example.yaml`), overlay kustomize per env, CronJob `expiry-sweep` 06:00 WIB (Asia/Jakarta), Terraform DB `pedaree` dengan password dikelola RDS, ArgoCD per env, runbook deploy/rollback (PDR-OPS-003).

### Diubah
- `k8s/backend.yaml` pindah ke `k8s/base/`; `argocd/backend.yaml` diganti tiga Application per env; `PAWONEE_RECIPE_API` tidak lagi memakai host contoh (asumsi host: `api.pawonee.chefgenie.id`).
