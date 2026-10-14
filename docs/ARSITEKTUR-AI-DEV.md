> Versi: v1.0.0 | Status: disetujui | Menggantikan: -

# ARSITEKTUR-AI-DEV — Stack terkunci dan batas context (pedaree-infra-devops)

Mengacu: Pedaree-TownHall `platform/versions/v1.0.0` (https://github.com/Coding-Skuy/Pedaree-TownHall/tree/main/platform/versions/v1.0.0), beku 2026-10-07. Dokumen ini MELENGKAPI `versions/v1.0.0/docs/40-TECHSTACK.md` dan `versions/v1.0.0/docs/60-BLAST-RADIUS.md` (keduanya beku v1.0.0 dan tidak diedit; isinya hanya ringkasan satu paragraf). Tidak menduplikasi BRD/PRD/FRD/FSD/SRS.

Baris Pedaree townhall-roadmap §2: point of concern "FEFO; stockout <8%; waste <1.500 g/Rp50.000/bln"; batas context "13 satuan baku; konsumen modul `pantry-resep` milik Pawonee". Rujukan lintas divisi: KONTEKS §3.1, §6, §8, §9.

## 1. Matriks stack

| Komponen | Kondisi saat ini (tercatat dari manifes/README) | Target terkunci v1.0.0 |
|---|---|---|
| IaC | Terraform 1.10.5 | Terraform (eksak saat kickoff) |
| Orkestrasi | Kubernetes 1.32.2 + ArgoCD 2.14.3 | k8s + ArgoCD |
| Kontainer | Docker 27.4.0 | Docker |
| Data | PostgreSQL 16.6, Redis 7.4.1 | PostgreSQL 16.x (DB `pedaree`); Redis hanya bila ada ADR |
| CI backend | Rust 1.84.1 | Rust stabil terbaru (mengikuti backend) |
| CI web | setup-node 4.1.0 | Bun (mengikuti migrasi web) |
| Image backend | `ghcr.io/coding-skuy/pedaree-backend-service:0.1.0` | versi rilis semver per rilis |

## 2. Drift yang tercatat

- `k8s/backend.yaml` memakai host contoh untuk `PAWONEE_RECIPE_API` dan probe `/kesehatan`; selaraskan dengan API v1.
- CI web masih mengacu Node (`actions/setup-node`); diselaraskan setelah tiket `PDR-WEB-002` selesai.

## 3. Boleh disentuh repo ini

- `terraform/`, `k8s/`, `argocd/`, `.github/workflows/`, runbook.
- Provisioning DB logis `pedaree` dan secrets per env.

## 4. Dilarang

- Menyimpan secret di repo atau membagikan service key lintas divisi.
- Mengubah kode/kontrak repo lain; hanya membangun dan men-deploy-nya.
- Deploy produksi tanpa QA gate hijau dan runbook rollback.
- Menyentuh DB divisi lain (DB per service; Titeny hanya read-only ke DB sumber).
- Membuat pesanan TitipO otomatis dari sinyal stok (hanya anjuran, relevansi 48 jam).
- Mengubah modul `:shared:pantry-resep` (milik Pawonee), daftar 13 satuan, ambang kedaluwarsa, atau audiens JWT tanpa PR TownHall + ADR.

## 5. Kontrak yang diproduksi

- Pipeline CI/QA gate, artefak APK/TestFlight, environment per env.
- Runbook deploy + rollback; jadwal `expiry-sweep`.

## 6. Kontrak yang dikonsumsi

- Repo `pedaree-backend-service`, `pedaree-web`, `pedaree-app-kmp`, `pedaree-ai-models`, `pedaree-data-pipeline`, `pedaree-design`.
- Service key TitipO (penerima `POST /sinyal/pedaree-stok`).

## 7. Dampak bila berubah

- Perubahan CI/secrets dapat memblokir seluruh rilis divisi.
- Secret/DB salah dapat memutus autentikasi (JWT audiens `pedaree`) dan pengiriman sinyal ke TitipO.

## Batasan

- Dokumen ini hanya mencatat stack dan batas; tidak mengubah manifes atau kode. Kondisi saat ini dicatat apa adanya.
- Versi dikunci eksak di manifes saat kickoff coding; perubahan dicatat lewat ADR baru.
- JWT audiens `pedaree`, DB logis `pedaree`, dan kepemilikan Pawonee atas `:shared:pantry-resep` tidak berubah oleh dokumen ini.
