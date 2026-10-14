# ADR-0001 — Fondasi teknis pedaree-infra-devops

Status: Diterima | Tanggal: 2026-10-14

## Konteks

Infra mengorkestrasi seluruh repo Pedaree dan menegakkan QA gate bersama. Sumber kebenaran: Pedaree-TownHall `platform/versions/v1.0.0` (https://github.com/Coding-Skuy/Pedaree-TownHall/tree/main/platform/versions/v1.0.0), beku 2026-10-07; lintas divisi: [KONTEKS-LINTAS-DIVISI.md](https://github.com/Coding-Skuy/ChefGenie-TownHall/blob/main/KONTEKS-LINTAS-DIVISI.md). Tiket fondasi: PDR-OPS-001 (issue #1).

## Keputusan

1. CI memblokir rilis bila `cargo test`, uji web, build APK KMP, atau pytest gagal.
2. Deploy per env lewat Terraform + k8s + ArgoCD; Postgres 16.x dengan DB logis `pedaree`; satu DB per service.
3. Secrets per env (`DATABASE_URL`, kunci JWT audiens `pedaree`, service key ke TitipO, API key device); service key least-privilege.
4. Job `expiry-sweep` dijadwalkan setiap hari 06:00 WIB.
5. Rilis mobile lewat Play Store internal, APK sideload, dan TestFlight; tidak ada target Windows untuk Pedaree.

## Konsekuensi

- Variabel `PAWONEE_RECIPE_API` di `k8s/backend.yaml` menunjuk host contoh (`api-pengembangan.pawonee.example.id`); harus diganti host resmi Pawonee.
- CI web harus berpindah dari Node ke Bun setelah migrasi `pedaree-web`.
- Rotasi secret menjadi tugas operasional terjadwal.
