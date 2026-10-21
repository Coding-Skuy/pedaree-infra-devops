# Runbook — deploy, secrets, expiry-sweep, rollback (PDR-OPS-003)

Env: `pengembangan` | `staging` | `produksi`. Namespace k8s `pedaree-<env>`. Prasyarat deploy produksi: QA gate hijau (`qa-gate`) dan runbook ini dibaca.

## 1. Provisioning DB `pedaree`
1. `terraform -chdir=terraform init && terraform -chdir=terraform apply -var-file=environments/<env>.tfvars`.
2. Kata sandi master dikelola RDS di Secrets Manager (`terraform output db_secret_arn`); jangan disalin ke repo.
3. Masuk sebagai master, buat pengguna aplikasi berhak minimal pada DB `pedaree` saja (`CREATE ROLE pedaree_app LOGIN ...; GRANT ... ON DATABASE pedaree`). Satu DB per service: dilarang memberi akses ke DB divisi lain.
4. Terapkan migrasi dari `pedaree-backend-service/migrations/`.

## 2. Secrets per env
Secret yang dibutuhkan (nama Secret k8s): `pedaree-db` (`url`), `pedaree-jwt` (`signing-key`, audiens `pedaree`), `pedaree-titipo` (`service-key`, header `X-Service-Key`), `pedaree-device-keys` (`keys`). Templat: `.env.example` dan `secrets/pedaree-secrets.example.yaml` (placeholder saja).

```bash
# nilai dibaca dari .env.<env> lokal (diabaikan git); jangan ditempel ke riwayat shell/CI log
kubectl -n pedaree-<env> create secret generic pedaree-db --from-literal=url="$DATABASE_URL" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n pedaree-<env> create secret generic pedaree-jwt --from-literal=signing-key="$JWT_SIGNING_KEY" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n pedaree-<env> create secret generic pedaree-titipo --from-literal=service-key="$TITIPO_SERVICE_KEY" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n pedaree-<env> create secret generic pedaree-device-keys --from-literal=keys="$DEVICE_API_KEYS" --dry-run=client -o yaml | kubectl apply -f -
```
Service key TitipO dibatasi ke endpoint sinyal; tidak ada kunci yang membuka DB divisi lain.

### Rotasi
Catat tanggal rotasi di tiket operasional. Rotasi service key: minta kunci baru ke TitipO, update `pedaree-titipo`, `kubectl -n pedaree-<env> rollout restart deploy/pedaree-backend`, lalu minta TitipO mencabut yang lama. Rotasi kunci JWT: dua kunci aktif bersama sementara (token akses 15 menit, refresh 7 hari) sampai refresh lama kedaluwarsa; detail menunggu kontrak backend.

## 3. Deploy
ArgoCD: `kubectl apply -f argocd/backend-<env>.yaml`. pengembangan/staging sinkron otomatis; produksi sinkron manual (`argocd app sync pedaree-backend-produksi`) setelah QA gate hijau. Ganti tag image di `k8s/base/*.yaml` (semver rilis) lewat PR.

## 4. expiry-sweep (06:00 WIB, BR-202)
CronJob `pedaree-expiry-sweep` (`schedule: "0 6 * * *"`, `timeZone: Asia/Jakarta`, `concurrencyPolicy: Forbid`).
- Cek: `kubectl -n pedaree-<env> get cronjob,jobs`; log: `kubectl -n pedaree-<env> logs job/<nama-job>`.
- Jalankan manual: `kubectl -n pedaree-<env> create job --from=cronjob/pedaree-expiry-sweep sweep-manual-$(date +%s)`.
- Jeda sementara: `kubectl -n pedaree-<env> patch cronjob pedaree-expiry-sweep -p '{"spec":{"suspend":true}}'` (kembalikan `false`).
- Catatan: sweep idempoten dan tidak membuat pesanan TitipO (hanya sinyal anjuran). ASUMSI: backend menyediakan subperintah `expiry-sweep`; belum ada di `main` backend.

## 5. Rollback
1. Aplikasi: `argocd app history pedaree-backend-<env>` lalu `argocd app rollback pedaree-backend-<env> <ID>`; atau `git revert` PR rilis dan sinkronkan. Untuk pengembangan/staging matikan auto-sync lebih dulu agar rollback tidak ditimpa.
2. Secret: kembalikan nilai lama dari secret manager/operator lalu `rollout restart`.
3. Migrasi DB: hanya maju; rollback lewat migrasi korektif atau pemulihan snapshot RDS (retensi di `terraform/environments/<env>.tfvars`). Jangan `terraform destroy` produksi (`deletion_protection` aktif).
4. Verifikasi: `GET /kesehatan` 200 dan CronJob berikutnya sukses.
