# Runbook — rilis dan rollback mobile (PDR-OPS-004)

Jalur: APK sideload (GitHub Release), AAB ke Play Store track `internal`, IPA ke TestFlight. Tidak ada MSIX/EXE Windows untuk Pedaree (job `tanpa-windows` menggagalkan rilis bila ada). Workflow: `.github/workflows/mobile-release.yml`.

## 1. Prasyarat (sekali)
Secret repo/environment `rilis-mobile` (aktifkan reviewer wajib pada environment ini). Semua nilai diisi manual oleh pemilik; tidak ada di repo.

| Secret | Isi |
|---|---|
| `CI_REPO_TOKEN` | token baca-saja ke repo `pedaree-*` |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | keystore rilis (`base64 -i rilis.jks`) |
| `PLAY_SERVICE_ACCOUNT_JSON` | JSON service account Play Console (izin rilis track internal) |
| `IOS_CERT_P12_BASE64`, `IOS_CERT_PASSWORD`, `IOS_PROVISION_PROFILE_BASE64` | sertifikat distribusi dan profil App Store |
| `APPSTORE_KEY_ID`, `APPSTORE_ISSUER_ID`, `APPSTORE_API_KEY_P8` | kunci API App Store Connect |

Simpan cadangan keystore Android di tempat aman terpisah: kehilangan keystore berarti tidak bisa merilis pembaruan.

## 2. Rilis
1. Pastikan `qa-gate` hijau untuk ref yang dirilis.
2. Naikkan versi di `pedaree-app-kmp` (`versionCode`/`versionName`), merge.
3. Beri tag: `git tag mobile-vX.Y.Z && git push origin mobile-vX.Y.Z` (atau jalankan manual `mobile-release` dengan `kirim_play`/`kirim_testflight`).
4. Workflow: `qa` -> `android` + `ios` (butuh persetujuan environment) -> `tanpa-windows` -> `rilis-github` (pra-rilis berisi APK).
5. Play Console: rilis berstatus draft di track internal; tinjau lalu promosikan ke penguji internal. TestFlight: build muncul setelah diproses Apple (menit hingga jam); tambahkan ke grup penguji.
6. APK sideload: unduh dari GitHub Release, verifikasi `apksigner verify --print-certs` cocok dengan sertifikat rilis.

## 3. Rollback
- **Play internal**: Play tidak menerima downgrade `versionCode`. Hentikan/halt rilis draft bermasalah, lalu terbitkan ulang build lama dengan `versionCode` baru (tag `mobile-vX.Y.(Z+1)`).
- **TestFlight**: kedaluwarsakan build bermasalah di App Store Connect, hentikan distribusi ke grup; unggah build perbaikan dengan nomor build lebih tinggi.
- **APK sideload**: tandai GitHub Release bermasalah sebagai pra-rilis/hapus aset, publikasikan APK versi sebelumnya; penguji memasang ulang (downgrade perlu uninstall bila `versionCode` lebih kecil).
- Bila penyebab di backend, rollback backend mengikuti runbook deploy (PDR-OPS-003, `docs/runbook/RUNBOOK-DEPLOY-ROLLBACK.md` setelah merge) dan koordinasikan kompatibilitas kontrak API.

## 4. Catatan asumsi
Id aplikasi `com.pedaree.app`, proyek Xcode `iosApp/iosApp.xcodeproj` skema `iosApp`, dan `iosApp/ExportOptions.plist` (method `app-store`) belum ada di `pedaree-app-kmp` (baru berisi `composeApp`); harus disediakan tiket app-kmp. Penandatanganan Android memakai `-Pandroid.injected.signing.*` sehingga tidak perlu mengubah Gradle.
