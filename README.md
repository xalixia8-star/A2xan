# Vaulte

![Build Vaulte](https://github.com/OWNER/REPO/actions/workflows/build.yml/badge.svg)

> Ganti `OWNER/REPO` pada badge di atas dengan nama repository GitHub Anda.

Password manager **offline** untuk Android & iOS (Flutter). Semua sandi disimpan
terenkripsi di perangkat. Tanpa analytics, tanpa pelacak, tanpa izin INTERNET.

## Fitur

Splash animasi, onboarding 3 halaman, master password dengan indikator kekuatan,
login + biometrik (Face ID / sidik jari), vault dengan pencarian / filter
kategori / sort, grid ikon layanan bergaya iPhone (120+ layanan + Custom),
generator password (8-64 karakter), favorit, backup & restore terenkripsi,
auto-lock, dan pembersihan clipboard otomatis.

## Keamanan

| Aspek | Implementasi |
|---|---|
| Enkripsi data | AES-256-GCM (paket `cryptography`, native lewat `cryptography_flutter`) |
| Turunan kunci | PBKDF2-HMAC-SHA256, **600.000 iterasi** (minimum 310.000), salt acak 16 byte |
| Master password | Tidak pernah disimpan. Hanya membungkus kunci data (DEK) acak 256-bit |
| Penyimpanan kunci | `flutter_secure_storage` → Keychain (iOS) / Keystore (Android) |
| Auto-lock | Idle (30 dtk / 1 mnt / 5 mnt) dan saat kembali dari background setelah melewati batas yang sama |
| Anti-screenshot | Android: `FLAG_SECURE`. iOS: overlay blur saat app tidak aktif |
| Clipboard | Dibersihkan otomatis 15 / 30 / 60 dtk |
| Login salah | 3x gratis, lalu delay 30 dtk, 60 dtk, 2 mnt ... maks 15 mnt (tersimpan, tahan restart) |
| Backup | Berkas `.vaulte` terenkripsi AES-256-GCM dengan password backup terpisah |

Catatan jujur: PBKDF2 dipakai (bukan Argon2id) karena tersedia native di kedua
platform. Master password yang lupa **tidak dapat dipulihkan**.

## Struktur

```
lib/
  core/       crypto, security (secure store, biometrik, limiter), utils
  data/       models, catalog layanan, repository terenkripsi, providers (Riverpod)
  features/   splash, onboarding, auth, vault, generator, settings, shell
  shared/     widget bersama (ikon squircle, tombol, dialog, empty state)
  theme/      app_colors.dart + app_theme.dart (satu-satunya sumber warna)
platform/     template Android (MainActivity + FLAG_SECURE)
tools/        bootstrap.sh + patch_platforms.py
.github/workflows/build.yml
```

## Menjalankan lokal

Prasyarat: Flutter stable terbaru, Python 3, curl. (Android: JDK 17 + Android SDK.
iOS: macOS + Xcode.)

```bash
bash tools/bootstrap.sh     # sekali: buat android/ & ios/, terapkan konfigurasi,
                            # unduh font (Cormorant Garamond, Inter) & ikon brand
flutter pub get
flutter run                 # perangkat / emulator
flutter test
```

Uji performa 120 Hz memakai profile mode pada perangkat fisik:

```bash
flutter run --profile
```

Ikon brand diunduh dari `simple-icons` (CC0). Layanan yang tidak punya logo di
paket tersebut (mis. bank & dompet digital lokal) otomatis memakai **inisial
huruf** di atas squircle warna brand.

## Build rilis lokal

```bash
flutter build apk --release --split-per-abi
flutter build appbundle --release
flutter build ios --release --no-codesign
```

## GitHub Actions

Workflow `.github/workflows/build.yml` berjalan pada setiap push (semua branch),
pull request ke `main`, dan manual (**Actions → Build Vaulte → Run workflow**).
Build lama pada ref yang sama otomatis dibatalkan.

1. **build-android** (Ubuntu): bootstrap → pub get → analyze → test → APK (split ABI) + AAB.
2. **build-ios** (macOS): bootstrap → build `--no-codesign` → paket `.ipa` unsigned.
3. **release**: hanya saat push tag `v*`, membuat GitHub Release berisi APK/AAB/IPA.

### Mengunduh hasil build

Repository → tab **Actions** → pilih run → bagian **Artifacts** di bawah halaman:
`vaulte-apk`, `vaulte-aab`, `vaulte-ipa-unsigned` (disimpan 14 hari).

### Signing Android (opsional)

Tanpa secrets, build memakai debug key (cukup untuk uji coba). Untuk rilis:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
base64 -w0 upload-keystore.jks      # macOS: base64 -i upload-keystore.jks
```

Settings → Secrets and variables → Actions → New repository secret:

| Secret | Isi |
|---|---|
| `KEYSTORE_BASE64` | hasil base64 keystore |
| `KEYSTORE_PASSWORD` | password keystore |
| `KEY_ALIAS` | alias (mis. `upload`) |
| `KEY_PASSWORD` | password key |

Simpan keystore Anda di tempat aman; kehilangannya berarti tidak bisa memperbarui
aplikasi di Play Store.

### Membuat rilis

```bash
git tag v1.0.0 && git push origin v1.0.0
```

### iOS

IPA hasil CI **tidak ditandatangani**. Untuk memasang ke perangkat / App Store,
tanda tangani dengan sertifikat Apple Developer Anda (mis. Xcode, Sideloadly,
atau menambahkan langkah signing ke workflow).

## Lisensi font & ikon

Cormorant Garamond & Inter: SIL OFL. simple-icons: CC0. Logo adalah milik
masing-masing pemilik merek dan dipakai hanya sebagai penanda layanan.
