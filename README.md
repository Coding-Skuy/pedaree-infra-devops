# pedaree-infra-devops — Infrastruktur dan Rilis Pedaree

Divisi **Pedaree (Smart Pantry)**, org **Coding-Skuy**. Opsi A.

TownHall: https://github.com/Coding-Skuy/Pedaree-TownHall

## Ringkasan

Infrastruktur sebagai kode dan alur rilis untuk semua layanan Pedaree:
backend Rust, web, pipeline data, dan penyajian model. Satu pintu masuk
untuk provisi, sebar, dan pantau.

## Modul pantry-resep

Kontrak lintas divisi (detail: `docs/MODUL-PANTRY-RESEP.md`):

- **Pemilik modul:** Pawonee.
- **Konsumen modul:** Pedaree (variabel lingkungan `PAWONEE_RECIPE_API`
  disuntik saat sebar agar backend Pedaree dapat memanggil API resep Pawonee).
- Nilai baku menunjuk ke lingkungan pengembangan Pawonee; nilai produksi
  diisi melalui rahasia repositori.

## Teknologi (versi dikunci)

- Terraform 1.10.5
- Kubernetes 1.32.2
- ArgoCD 2.14.3
- Docker 27.4.0
- PostgreSQL 16.6, Redis 7.4.1
- GitHub Actions: actions/checkout 4.2.2, actions/setup-node 4.1.0,
  actions-rs/toolchain 1.0.7

## Struktur

```text
terraform/         modul provisi (db pedaree, antrean, jaringan)
k8s/               manifes sebar tiap layanan
argocd/            definisi aplikasi ArgoCD
docs/              arsitektur dan kontrak modul
```

## Cara pakai

```bash
terraform -chdir=terraform init
terraform -chdir=terraform validate
kubectl apply -k k8s/overlays/pengembangan
```

## CI

Workflow `.github/workflows/ci.yml` menjalankan validasi Terraform dan
pemeriksaan manifes Kubernetes.
