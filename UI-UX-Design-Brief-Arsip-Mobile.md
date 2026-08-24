# UI/UX Design Brief — Aplikasi Mobile Approval Arsip

**Target pengguna:** Pimpinan/pejabat berwenang (bukan staf teknis) — jadi UI harus *simpel, besar, jelas, minim friksi*.
**Prinsip desain:** Profesional, clean, trustworthy (nuansa institusi/pemerintahan/korporat), dominan **putih + biru**.

---

## 1. Design System

### 1.1 Palet Warna

| Token | Hex | Penggunaan |
|---|---|---|
| `primary-blue` | `#1E4FD6` (Indigo Blue) | Tombol utama, header, active state, ikon aktif |
| `primary-blue-dark` | `#13358F` | Pressed state, gradient akhir |
| `primary-blue-light` | `#E8EEFC` | Background card terpilih, badge info, chip |
| `surface-white` | `#FFFFFF` | Background utama, card |
| `surface-soft` | `#F5F7FB` | Background layar (bukan card), pemisah section |
| `emerald-success` | `#0F9D58` | Status "Disetujui", sukses, badge approve |
| `amber-warning` | `#F5A623` | Status "Menunggu", pending, badge disposisi baru |
| `red-danger` | `#E53935` | Status "Ditolak", error, tombol reject |
| `text-primary` | `#0F172A` | Judul, teks utama |
| `text-secondary` | `#64748B` | Sub-teks, caption, metadata |
| `border-subtle` | `#E2E8F0` | Border card, divider |

> Rasio putih:biru ≈ 75%:20%, sisanya 5% aksen status (emerald/amber/red) — biru selalu jadi warna dominan aktif, bukan warna pemenuh layar.

### 1.2 Tipografi
- Font: **Inter** atau **Plus Jakarta Sans** (modern, sangat mudah dibaca di layar kecil, kesan profesional-formal).
- Skala: H1 24/700, H2 20/700, H3 16/600, Body 14/400, Caption 12/400, Button 15/600.
- Angka statistik dashboard pakai varian **Tabular Numbers** agar rapi sejajar.

### 1.3 Komponen Kunci
- **Card**: radius 16px, shadow tipis `0 2px 8px rgba(15,23,42,0.06)`, padding 16px.
- **Button primary**: filled biru, radius 12px, height 52px, full-width di form/aksi penting.
- **Button secondary/outline**: border biru 1.5px, teks biru, background putih.
- **Status Badge (pill)**: radius full, padding 4-10px, warna sesuai status (amber/emerald/red) dengan background versi 10% opacity dari warna solidnya.
- **Bottom Navigation Bar**: 4-5 item, ikon outline saat inactive → ikon filled + warna biru saat active, indikator garis kecil di atas ikon aktif.
- **App Bar**: putih bersih, judul kiri, notifikasi bell kanan (dengan dot merah unread), tanpa shadow berat — cukup 1px border bawah.

### 1.4 Motion & Feedback
- Transisi antar layar: slide horizontal 250ms ease-out.
- Loading: skeleton shimmer (bukan spinner polos) untuk list & card statistik.
- Pull-to-refresh dengan warna biru primary.
- Micro-interaction saat approve: checkmark animasi + haptic feedback ringan.

---

## 2. Navigasi & Information Architecture

```
Bottom Navigation (4 tab):
[Dashboard] [Approval] [Disposisi] [Profil]
      + Notification icon di App Bar (bukan tab, karena sifatnya transient)
```

Alasan: pejabat butuh 2 aksi utama (approval surat keluar & disposisi surat masuk) selalu 1-tap accessible, dashboard sebagai home, profil untuk logout/pengaturan.

---

## 3. Pemetaan UI/UX per Layar

### 3.1 Login Screen
**Tujuan UX:** Kesan pertama harus trustworthy & cepat — pejabat tidak mau berlama-lama di form.

**Prompt desain:**
> Buat halaman login mobile dengan background putih bersih. Bagian atas (40% tinggi layar) berisi logo instansi di tengah dengan sedikit gradient biru lembut (`primary-blue` ke `primary-blue-dark`) sebagai aksen dekoratif di belakang logo, bentuk lengkung/wave di bagian bawahnya menyatu ke area putih. Di bawahnya, judul "Selamat Datang" (H1, bold) dan subjudul "Masuk untuk mengelola approval surat" (text-secondary). Form terdiri dari 2 input field bergaya outlined rounded (radius 12px) dengan label mengambang: Username/NIP dan Password (dengan ikon show/hide password). Tombol "Masuk" full-width warna primary-blue dengan radius 12px, height 52px, disertai loading spinner putih saat proses submit. Tambahkan teks kecil "Lupa Password?" di kanan bawah form (warna biru). Tampilkan pesan error dari backend dalam bentuk banner merah muda tipis di atas form jika login gagal. Seluruh layout harus terasa lega dengan padding horizontal 24px.

---

### 3.2 Dashboard Screen
**Tujuan UX:** Ringkasan sekali lihat (glanceable), pejabat langsung tahu apa yang perlu ditindaklanjuti tanpa scroll banyak.

**Prompt desain:**
> Buat halaman dashboard mobile dengan app bar putih menampilkan "Halo, [Nama Pejabat]" dan sub-teks jabatan/cabang di bawahnya (kiri), serta ikon lonceng notifikasi dengan badge merah di kanan. Di bawah app bar, tampilkan grid 2x2 stat card dengan background putih, radius 16px, shadow halus: "Menunggu Approval" (angka besar warna amber, ikon dokumen jam), "Disetujui" (angka besar warna emerald, ikon centang), "Ditolak" (angka besar warna merah, ikon silang), "Disposisi Aktif" (angka besar warna biru, ikon inbox). Setiap card bisa di-tap untuk langsung ke list terkait. Di bawah grid, tampilkan card "Tren Mingguan" berisi bar chart atau line chart sederhana warna biru gradient menunjukkan jumlah approval per hari dalam seminggu terakhir. Di bagian paling bawah, section "Aktivitas Terbaru" berupa list vertikal item audit log — setiap item berisi ikon bulat kecil (status color), judul aktivitas, dan timestamp relatif ("2 jam lalu") dengan divider tipis antar item. Seluruh halaman mendukung pull-to-refresh dengan indicator biru.

---

### 3.3 Approval List Screen
**Tujuan UX:** Prioritas pada dokumen yang butuh perhatian segera; scanning cepat lewat status badge, bukan baca detail satu-satu.

**Prompt desain:**
> Buat halaman daftar approval surat keluar. App bar putih dengan judul "Approval Surat" dan search bar rounded (radius 24px, background `surface-soft`) tepat di bawahnya berisi placeholder "Cari nomor atau perihal surat". Di bawah search bar, tampilkan filter chip horizontal scrollable: "Semua", "Menunggu", "Disetujui", "Ditolak" — chip aktif berwarna primary-blue solid dengan teks putih, chip inactive berwarna putih dengan border abu tipis. List di bawahnya berupa card vertikal per surat: baris atas berisi nomor surat (bold, text-primary) dan status badge pill di kanan (amber/emerald/red sesuai status); baris tengah perihal surat (2 baris max, ellipsis); baris bawah berisi metadata kecil — nama pengaju, cabang, dan tanggal (text-secondary, dengan ikon kecil). Tambahkan chevron kanan sebagai afordansi bahwa card bisa di-tap. Beri sedikit left-border 3px berwarna status di sisi kiri card untuk scan visual super cepat. Tampilkan empty state ilustratif (ikon dokumen biru muda + teks "Tidak ada surat menunggu approval") bila list kosong.

---

### 3.4 Approval Detail Screen
**Tujuan UX:** Ini layar paling kritis — pejabat harus bisa membaca surat, memahami konteks, lalu approve/reject dengan yakin dan cepat.

**Prompt desain:**
> Buat halaman detail approval surat. App bar putih dengan tombol back dan judul "Detail Surat". Bagian atas berupa card informasi surat: nomor surat (bold besar), status badge, perihal, tanggal pengajuan, nama & jabatan pengaju, cabang asal — disusun sebagai label-value list rapi dengan label warna text-secondary kecil dan value warna text-primary. Di bawahnya, section "Alur Tracking" ditampilkan sebagai timeline vertikal (garis penghubung biru muda dengan titik bulat solid untuk tahap yang sudah lewat berwarna emerald, titik outline untuk tahap yang akan datang) — setiap titik menunjukkan nama tahap, PIC, dan tanggal/waktu. Selanjutnya section "Preview Dokumen" berupa card dengan tombol "Lihat PDF Surat" (icon dokumen biru) yang membuka PDF viewer full-screen terintegrasi, lengkap dengan toolbar zoom dan navigasi halaman di bagian bawah viewer. Di bagian paling bawah layar (sticky/fixed), tampilkan dua tombol besar berdampingan: tombol outline merah "Tolak" (kiri) dan tombol solid emerald/biru "Setujui" (kanan), masing-masing 48% lebar layar, height 52px, radius 12px — area ini diberi sedikit shadow ke atas agar terlihat "mengambang" di atas konten saat scroll. Saat tombol "Setujui" ditekan, munculkan bottom sheet modal berisi konfirmasi TTE otomatis dengan preview tanda tangan digital dan tombol "Konfirmasi Persetujuan". Saat "Tolak" ditekan, munculkan bottom sheet modal dengan text area wajib diisi "Alasan Penolakan" dan tombol "Kirim Penolakan" (disabled sampai teks diisi).

---

### 3.5 Disposition List Screen
**Tujuan UX:** Aksi cepat (quick action) tanpa harus masuk ke detail — karena disposisi sifatnya operasional harian.

**Prompt desain:**
> Buat halaman daftar disposisi surat masuk. App bar putih judul "Disposisi Surat". List card per surat masuk mirip struktur approval list, namun setiap card memiliki 3 tombol aksi cepat kecil di baris bawah (chip/segmented button): "Dibaca", "Diproses", "Selesaikan" — status yang sedang aktif ditandai dengan background biru solid dan teks putih, status lain berupa outline. Tap salah satu tombol langsung mengubah status dengan animasi transisi warna dan toast konfirmasi kecil di bawah layar ("Status diperbarui ke Diproses"). Tambahkan badge kecil "Baru" berwarna amber di pojok kanan atas card untuk disposisi yang belum dibaca (unread), hilang otomatis setelah status "Dibaca" dipilih.

---

### 3.6 Notification Screen
**Tujuan UX:** Riwayat & aksi cepat langsung ke sumbernya.

**Prompt desain:**
> Buat halaman notifikasi dengan app bar putih judul "Notifikasi" dan tombol teks kecil "Tandai semua dibaca" di kanan. List notifikasi berupa item horizontal: ikon bulat berwarna (biru untuk approval baru, amber untuk disposisi baru, emerald untuk info disetujui) di kiri, judul notifikasi + preview singkat + timestamp relatif di tengah, dan dot kecil biru di kanan untuk item yang belum dibaca (hilang setelah dibaca). Notifikasi unread memiliki background `primary-blue-light` samar, notifikasi read berbackground putih polos. Tap item langsung navigasi ke Approval Detail atau Disposition List terkait.

---

### 3.7 Profile Screen
**Tujuan UX:** Ringkas, menonjolkan identitas jabatan (kredibilitas), akses logout jelas dan aman dari salah tap.

**Prompt desain:**
> Buat halaman profil dengan bagian atas berupa card gradient biru (`primary-blue` ke `primary-blue-dark`) berisi avatar bulat (inisial nama jika tanpa foto), nama lengkap (putih, bold), jabatan, dan nama cabang di bawahnya (putih dengan opacity lebih rendah). Di bawah card, list menu berupa item-item dengan ikon di kiri, label di tengah, chevron di kanan, dengan divider tipis: "Ubah Password", "Pengaturan Notifikasi", "Bantuan & Dukungan", "Tentang Aplikasi". Di paling bawah, tombol "Keluar" full-width dengan outline merah dan teks merah (bukan solid, agar tidak tertekan tidak sengaja), yang saat ditekan memunculkan dialog konfirmasi "Yakin ingin keluar dari aplikasi?" dengan dua tombol: "Batal" (outline) dan "Ya, Keluar" (solid merah).

---

## 4. Checklist Konsistensi Visual (untuk desainer/AI generator)

- [ ] Semua status (Menunggu/Disetujui/Ditolak) selalu pakai warna & ikon yang sama di seluruh layar (dashboard, list, detail, notifikasi).
- [ ] Tombol destruktif (Tolak, Keluar) **selalu** outline/secondary — tombol solid berwarna kuat direservasi untuk aksi positif (Setujui, Masuk, Konfirmasi).
- [ ] Radius komponen konsisten: card 16px, button 12px, chip/badge full-radius.
- [ ] Padding horizontal layar konsisten 20-24px di semua screen.
- [ ] Biru hanya dipakai untuk elemen aktif/interaktif/branding — bukan untuk background besar (agar tetap terasa "putih dominan").
- [ ] Kontras teks minimal WCAG AA (khusus untuk pejabat usia lebih senior — hindari abu-abu terlalu terang).

---

## 5. Rekomendasi Tools Implementasi Flutter
- Widget card & badge → buat sebagai reusable widget (`StatusBadge`, `AppCard`, `PrimaryButton`, `OutlineButton`) di `lib/screens/**/widgets/` agar konsisten dan sesuai struktur folder di implementation plan.
- Warna & tipografi → definisikan sebagai `ThemeData` terpusat di `config/app_theme.dart` (`ColorScheme`, `TextTheme`) supaya tidak hardcode hex di tiap screen.
- Icon set → gunakan `Phosphor Icons` atau `Lucide Icons` (outline style) agar konsisten dengan kesan modern-profesional, hindari Material icon default yang terkesan generik.
