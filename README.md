# Aplikasi Mobile Approval - Flutter

Aplikasi mobile Flutter khusus untuk pimpinan dan pejabat yang berwenang melakukan **Approval Surat Keluar** (disertai otomatisasi TTE) dan **Tindak Lanjut Disposisi Surat Masuk**.

Aplikasi ini menggunakan backend **Express.js** yang sudah ada (`express_arsip_be`) dan terhubung langsung ke database MySQL.

---

## 🚀 Fitur Utama Mobile

1. **Dashboard Monitoring Real-time**:
   - Kartu metrik ringkasan (Menunggu Approval, Disetujui, Ditolak, Disposisi).
   - Aktivitas riwayat log sistem terbaru.
   - Pull-to-refresh data.

2. **Modul Approval Surat Keluar**:
   - Filter surat berdasarkan status (`Menunggu Approval`, `Disetujui`, `Ditolak`).
   - Pencarian perihal, nomor surat, dan instansi tujuan.
   - Detail informasi surat keluar & riwayat *tracking*.
   - **Persetujuan (Approve) & Otomatisasi TTE**: Menyetujui surat keluar langsung menempelkan Tanda Tangan Elektronik (TTE) & QR Code pada PDF.
   - **Penolakan (Reject)**: Menolak surat keluar beserta pengisian alasan penolakan.

3. **Modul Disposisi Surat Masuk**:
   - Daftar disposisi surat yang ditujukan ke pejabat yang login.
   - Aksi cepat ubah status disposisi: `Diproses` dan `Selesai`.

4. **Koneksi Server Dinamis**:
   - Pengaturan Base URL API langsung dari halaman login (mendukung Android Emulator `10.0.2.2`, iOS Simulator `127.0.0.1`, atau IP LAN `192.168.x.x`).

---

## 🛠️ Cara Menjalankan Aplikasi

### 1. Prasyarat
- Flutter SDK (v3.0.0+)
- Android Studio / VS Code dengan Flutter Plugin
- Emulator Android / Device Fisik
- Backend `express_arsip_be` berjalan di port `8000`

### 2. Jalankan Backend Express.js
```bash
cd express_arsip_be
npm run dev
```

### 3. Jalankan Aplikasi Flutter
```bash
cd flutter_arsip_mobile
flutter pub get
flutter run
```

---

## 📁 Struktur Folder Codebase

```
flutter_arsip_mobile/
├── lib/
│   ├── main.dart                 # Entry point utama
│   ├── app.dart                  # MultiProvider & ThemeData app
│   ├── config/
│   │   ├── api_config.dart       # Endpoint API & IP Server Config
│   │   └── app_theme.dart        # Tema UI (Colors, Typography, Components)
│   ├── core/
│   │   ├── network/
│   │   │   └── api_client.dart   # Dio HTTP Client & Interceptor Headers
│   │   ├── storage/
│   │   │   └── secure_storage.dart # Encrypted Storage Token & Credential
│   │   └── utils/
│   │       └── date_formatter.dart # Formatting Tanggal & Waktu (WIB)
│   ├── models/                   # Data Models (User, Approval, Disposition, Dashboard)
│   ├── services/                 # API Repositories & HTTP Services
│   ├── providers/                # State Management (Provider Pattern)
│   └── screens/                  # Halaman Tampilan (Auth, Dashboard, Approval, Disposisi, Profil)
└── pubspec.yaml
```
