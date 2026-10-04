# Modul pantry-resep — Kontrak Pawonee (pemilik) dan Pedaree (konsumen)

TownHall Pedaree: https://github.com/Coding-Skuy/Pedaree-TownHall

## Kedudukan

- **Pemilik:** Pawonee.
- **Konsumen:** Pedaree infra (menyuntik `PAWONEE_RECIPE_API` saat sebar).

## Aturan konsumen (berlaku untuk infra-devops)

1. Variabel `PAWONEE_RECIPE_API` wajib ada di semua lingkungan sebar backend.
2. Nilai baku pengembangan: `https://api-pengembangan.pawonee.example.id`.
3. Nilai produksi diisi dari rahasia repositori, bukan dari berkas.
4. Pemeriksaan kesehatan sebar memverifikasi konektivitas baca ke API Pawonee.
