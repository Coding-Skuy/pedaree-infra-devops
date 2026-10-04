# Arsitektur pedaree-infra-devops

TownHall: https://github.com/Coding-Skuy/Pedaree-TownHall

## Lapisan

1. `terraform/`: VPC, PostgreSQL `pedaree`, Redis, topik Kafka.
2. `k8s/`: sebar `backend`, `web`, `pekerja-sinyal`, `penyaji-model`.
3. `argocd/`: satu aplikasi per layanan dengan sinkronisasi otomatis.

## Alur rilis

Push ke `main` -> CI hijau -> citra diberi label SHA -> ArgoCD menyelaraskan
klaster pengembangan -> promosi manual ke produksi.

## Keputusan

- Satu repositori infra untuk semua layanan Pedaree (Opsi A).
- Rahasia hanya lewat GitHub Secrets dan manajer rahasia klaster.
