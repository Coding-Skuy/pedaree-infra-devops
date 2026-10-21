# Panduan kontribusi — pedaree-infra-devops

Baca `AGENTS.md` dan ADR di `docs/decisions/` lebih dulu. Requirement hidup di `Pedaree-TownHall`; repo ini tidak menduplikasinya.

## Alur

1. Fork, lalu cabang dari `main`: `feat/<kode-tiket>-<slug>`, `fix/…`, `docs/…`, `chore/…`.
2. Satu cabang = satu tiket = satu PR. Commit atomik, konvensi `feat:`/`fix:`/`docs:`/`chore:`, bahasa Indonesia.
3. Perubahan perilaku wajib memperbarui `CHANGELOG.md`.
4. Jangan menaruh rahasia di git. Hanya `*.example` dengan placeholder.

## QA gate (QA-001..QA-003)

`.github/workflows/qa-gate.yml` menjalankan: `cargo test` (backend), `bun install` + `bun run check` + `bun test` (web), build APK KMP (`assembleDebug` + uji unit), `pytest` (ai-models, data-pipeline). Job akhir `gerbang` merah bila ada satu pun yang gagal atau terlewat.

- **QA-002**: workflow rilis (`mobile-release.yml`) memanggil `qa-gate` lewat `needs`; build/uji merah memblokir rilis.
- **QA-003 (regresi wajib uji)**: setiap perbaikan bug harus diawali uji yang gagal (merah) yang mereproduksi bug, dicommit lebih dulu atau di commit yang sama, baru kemudian perbaikan membuatnya hijau. PR perbaikan tanpa uji regresi ditolak. Cantumkan nama uji di deskripsi PR.
- **QA-001**: setiap acceptance criteria tiket menjadi uji otomatis di repo yang memilikinya.

### Menjalankan gate

Secret repo `CI_REPO_TOKEN` (token baca-saja `contents:read` ke repo `pedaree-*`) wajib ada, karena job mengambil repo lain. Jalankan manual: tab Actions > `qa-gate` > Run workflow, atau `gh workflow run qa-gate.yml`. Jadwal harian 06:00 WIB memantau regresi di `main`.

## Validasi lokal sebelum PR

```bash
actionlint .github/workflows/*.yml
yamllint .github k8s argocd
kubeconform -strict -ignore-missing-schemas k8s argocd
terraform -chdir=terraform init -backend=false && terraform -chdir=terraform validate
```
