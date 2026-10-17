# Trilingual Korean Offline Master (한국어 • Indonesia • English)

Aplikasi Android edukasi bahasa Korea modern, ringan, dan **100% FULL OFFLINE (Local-Only Architecture)**. Seluruh logika data (*embedded local backend*), database SQLite berindeks dengan 1.250+ kosakata umum lengkap, pemroses tata bahasa fonetik tanpa batasan pola, studio kustom perkenalan diri, checklist hafalan harian offline permanen, kurikulum standar EPS-TOPIK 7 level, dan antarmuka *frontend* terbungkus mandiri di dalam satu paket APK tanpa server cloud atau API eksternal. Performa sangat ringan, responsif seketika, dan hemat baterai.

---

## Fitur Utama & Keunggulan

### 1. Embedded Local Backend & Business Logic (Pure Dart & SQLite)
* **Unconstrained & Adaptive Rule-Based Grammar Engine**:
  - **Dukungan Bebas Pola Tanpa Pembatasan**: Menyesuaikan kalimat pendek maupun kalimat panjang tanpa memaksa subjek atau kata kerja default buatan. Mengetik satu kata benda (seperti "roti", "uang"), kata kerja tunggal ("makan", "tidur"), kata sifat ("cantik", "dingin"), maupun frasa arah ("ke pasar", "di rumah") akan langsung dianalisis sebagai unit independen beserta partikel aslinya tanpa distorsi.
  - **Injeksi Partikel Cerdas (Deteksi Batchim Otomatis)**:
    - **Topik**: `은` (ada batchim) / `는` (vokal).
    - **Subjek**: `이` (ada batchim) / `가` (vokal).
    - **Objek**: `을` (ada batchim) / `를` (vokal).
    - **Keterangan Tempat & Asal**: `에서` (lokasi aktivitas aktif / asal) / `에` (tujuan pergerakan/keberadaan statis).
    - **Keterangan Sarana & Arah**: `으로` (konsonan biasa) / `로` (vokal atau konsonan akhir 'ㄹ' / *Rieul batchim rule*).
  - **Auto-Update Seketika & Tombol Enter**:
    - Hasil terjemahan dan uraian tata bahasa langsung diperbarui secara *real-time* saat teks diketik atau diubah.
    - Dilengkapi tombol tindakan **"Jalankan (Enter)"** pada antarmuka serta dukungan tombol aksi *Send/Enter* pada keyboard virtual (`textInputAction: TextInputAction.send`).
  - **Predicate Conjugator**: Mengonjugasikan akar kata verba/adjektiva dasar secara otomatis ke:
    - *Informal Polite* (`-아요` / `-어요` / `-해요`)
    - *Formal Polite* (`-ㅂ니다` / `-습니다`)
    - *Bentuk Lampau* (`-았어요` / `-었어요` / `-했어요`)
    - *Bentuk Rencana/Masa Depan* (`-(으)ㄹ 거예요`)
    - *Bentuk Kamus Dasar* (`-다`)

* **Unicode Mathematical Deconstructor (`HangulSpeller`)**:
  - Mengurai suku kata Hangul (`0xAC00` – `0xD7A3`) menggunakan rumus matematika Unicode murni dengan memori 0 KB.
  - Memecah karakter menjadi **Choseong (초성)**, **Jungseong (중성)**, dan **Jongseong/Batchim (종성/받침)**.
  - Menghasilkan visualisasi formula ejaan: `"[ㄱ + ㅏ + ㅁ = 감] [ㅅ + ㅏ = 사]"`.
  - Romanisasi fonetik otomatis untuk suku kata dan kata utuh.

* **Embedded Storage Engine (SQLite via `sqflite`)**:
  - Database terindeks `assets/db/dictionary.db` (versi 3) di-bundle langsung di dalam APK.
  - Berisi **1.259 entri kosakata & frasa trilingual komprehensif** yang dibagi ke dalam **15 kategori aktivitas tematik**.
  - Mekanisme **`DatabaseHelper` (Singleton)** mengelola salinan database aman, *auto-migration* mandiri, dan pelacakan checklist hafalan.
  - Skrip DDL SQL inisialisasi dan *seed data* lengkap di `assets/sql/init.sql`.

* **Offline Dual-Speed Audio Engine (`flutter_tts`)**:
  - Mengintegrasikan sintesis ucapan lokal bawaan Android untuk bahasa Korea (`ko-KR`).
  - **Tombol Normal Speaker**: Memutar audio pelafalan alami dengan kecepatan wajar (0.45x).
  - **Tombol Kura-kura (Turtle Slow Mode)**: Memutar audio pelafalan lambat (0.22x) dengan animasi detak halus agar pembelajar dapat menangkap artikulasi konsonan akhir (*batchim*) secara presisi.

---

### 2. Studio Kustom Perkenalan Diri (Custom Self-Introduction Studio)
Fitur interaktif untuk menyusun teks perkenalan diri profesional maupun santai yang dapat disesuaikan sepenuhnya:
- **Parameter Kustomisasi Lengkap**:
  - Nama Lengkap / Panggilan.
  - Pekerjaan Sebelumnya (misal: Teknisi Pabrik, Staf Kantor, Pengelasan, dll.).
  - Lulusan Asal Sekolah / Universitas (misal: SMK Teknik Mesin, Universitas Indonesia, dll.).
  - Asal Daerah / Kota di Indonesia (misal: Jakarta, Surabaya, Cilacap, dll.).
  - Tujuan Kedatangan ke Korea (Bekerja di manufaktur, menempuh studi S1/S2, pelatihan kerja, dll.).
- **Dua Ragam Bahasa**:
  - *Wawancara Resmi (Formal / 격식체)*: Memakai akhiran `-(스)ㅂ니다` untuk wawancara kerja HRD atau visa kedutaan.
  - *Percakapan Santai (Informal Sopan / 비격식 존댓말)*: Memakai akhiran `-아요/어요` untuk sosialisasi harian.
- **Dukungan Audio Per Kalimat**: Dilengkapi tombol pemutar normal dan kura-kura lambat untuk setiap kalimat perkenalan.

---

### 3. Checklist Hafalan Saya (Daily Agenda Memorization Tracker)
Menu khusus untuk menandai dan melacak kosakata yang sudah dihafal secara mandiri:
- **9 Agenda Kontekstual Sehari-hari (90 Kosakata & Kalimat Wajib Hafal)**:
  1. *Pagi & Bangun Tidur*: Rutinitas jam 6 pagi, cuci muka, sikat gigi, sarapan.
  2. *Perjalanan & Transportasi*: Naik subway, isi kartu transportasi, halte bus, tiket.
  3. *Tempat Kerja & Belajar*: Jam masuk kerja, menyalakan mesin, berkas laporan, lembur.
  4. *Makan Siang & Restoran*: Memesan makanan, minta air, rasa makanan, bon kasir.
  5. *Belanja & Pasar*: Menanyakan harga, tawar diskon, pembayaran kartu, kantong belanja.
  6. *Kesehatan & Apotek*: Beli obat flu, sakit kepala, aturan minum obat, ambulans.
  7. *Sore & Hobi / Santai*: Berolahraga, menonton drama, musik K-Pop, jalan santai.
  8. *Malam & Waktu Tidur*: Mengunci pintu, mencuci pakaian, ucapan selamat tidur.
  9. *Kalimat Sederhana Wajib*: Maaf, terima kasih, tolong bicara pelan-pelan, permisi.
- **Penyimpanan Permanen Offline**: Status centang (ceklis / unceklis) tersimpan otomatis ke SQLite lokal sehingga progres belajar tidak pernah hilang meskipun aplikasi ditutup.
- **Filter Fleksibel & Statistik Progres**: Filter berdasarkan agenda dan status hafalan (Semua, Belum Hafal, Sudah Terhafal) dengan bilah persentase capaian.

---

### 4. Kamus Trilingual Komprehensif (1.250+ Kosakata Umum)
Kamus umum lengkap (*general dictionary*) agar pengguna dapat mencari kata apa saja yang diperlukan sehari-hari:
- **15 Kategori Tematik Lengkap**:
  1. *Perkenalan Diri*: Identitas, usia, negara, kebangsaan, visa, ARC, tujuan.
  2. *Kata Ganti & Sosial*: Pronoun lengkap (saya, kamu, kami, kita, bersama, sendiri), sapaan, gelar, anggota keluarga.
  3. *Restoran & Makan*: Nasi, sup, daging, seafood, sayuran, bumbu dapur, hidangan populer Korea, alat makan, kalimat pesanan.
  4. *Belanja & Supermarket*: Uang tunai, kartu, kasir, minimarket, pasar, diskon, kuitansi, ukuran pakaian.
  5. *Tidur & Rutinitas*: Perabotan rumah tangga, peralatan mandi, kebersihan, pemilahan sampah, salam tidur.
  6. *Arah & Jalan*: Navigasi arah mata angin, kanan, kiri, lurus, zebra cross, rambu, fasilitas kota.
  7. *Transportasi*: Subway, kereta cepat KTX, bus antarkota, taksi, bandara, kartu transit, tarif.
  8. *Kantor & Belajar*: Profesi, hierarki jabatan, kontrak kerja, gaji, lembur, perkakas bengkel, alat pelindung diri (APD).
  9. *Pendidikan & Sekolah*: Jenjang sekolah, perkuliahan, ujian, beasiswa, alat tulis kantor lengkap.
  10. *Kesehatan & Darurat*: Anatomi tubuh lengkap, gejala penyakit, poli rumah sakit, apotek, obat-obatan, nomor darurat.
  11. *Pakaian & Warna*: Busana pria/wanita, alas kaki, aksesoris, serta palet warna lengkap.
  12. *Emosi & Cuaca*: Perasaan hati, kondisi cuaca, 4 musim, fenomena alam, hewan dan tanaman.
  13. *Waktu & Angka*: Jam, menit, hari, bulan, tahun, angka Sino-Korea, angka Asli Korea, dan satuan penghitung (counters).
  14. *Kata Kerja (Aksi)*: Ratusan kata kerja tindakan fisik, mental, sosial, dan komunikasi sehari-hari.
  15. *Kata Sifat (Sifat & Rasa)*: Ratusan kata sifat kondisi fisik, rasa makanan, suhu, kepribadian, dan visual.
  16. *Tata Bahasa & Partikel*: Partikel penanda peran gramatikal kalimat.
- **Pencarian Cerdas Instan**: Pencarian multi-arah dalam aksara Hangul, ejaan Latin / Romanisasi, Bahasa Indonesia, maupun Bahasa Inggris.

---

### 5. Kurikulum Standar EPS-TOPIK & Latihan Soal Ujian
- **Kurikulum Resmi HRD Korea (Bab 1 s.d. 60)**: Terbagi ke dalam 7 tingkatan pembelajaran progresif dengan naskah dialog penutur asli, daftar kosakata, pola kalimat, dan latihan pemahaman.
- **Latihan Ujian Bertingkat (TOPIK I)**:
  - Paket Level 1 diperkaya menjadi 15 soal komprehensif mengikuti tren ujian 2 tahun terakhir.
  - Pembahasan detail dwibahasa di setiap butir soal: *Petunjuk Penyelesaian (Bahasa Indonesia)* dan *핵심 해설 & 힌트 (한국어)* dengan audio TTS normal dan kura-kura lambat.
  - Paket Level 2 (Struktur Kalimat SOV & Arah), Level 3 (Konjugasi Sopan & Lampau), dan Level 4 (TOPIK I Mastery).

---

### 6. Lima Menu Navigasi Utama (Material 3 NavigationBar)
1. **Parser SOV (Menu 1)**: Pembuat kalimat fleksibel tanpa batasan pola, dilengkapi tombol Enter, shortcut studio perkenalan diri, dan kartu konjugasi 5 bentuk.
2. **Kamus (Menu 2)**: Kamus trilingual 1.250+ kosakata dengan filter 15 aktivitas dan filter kelas kata POS, bebas dari overflow tampilan.
3. **Hafalan (Menu 3)**: Checklist hafalan harian 9 agenda dengan penyimpanan otomatis permanen ke SQLite dan indikator statistik progres.
4. **Latihan (Menu 4)**: Penjelajah kurikulum resmi EPS-TOPIK 60 bab dengan dialog bersuara dan latihan interaktif.
5. **Ujian (Menu 5)**: Paket kuis ujian bertingkat dengan analisis pembahasan mendalam dwibahasa (Indonesia & Korea).

---

## Struktur Proyek

```text
mobile_korea_id/
├── .gitignore                     # Mengecualikan dokumen/ (PDF & MP3 ~800MB) dan scratch/ dari git
├── android/
│   └── .gitignore                 # Mengecualikan dokumen/ pada level android
├── assets/
│   ├── db/
│   │   └── dictionary.db          # Binary SQLite database terindeks (1.259 kosakata & 30 soal ujian)
│   └── sql/
│       └── init.sql               # Skrip DDL tabel & data seed kamus 15 kategori, hafalan, dan ujian
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_theme.dart     # Design tokens Material 3, skema warna, typography, card shadows
│   │   ├── engine/
│   │   │   ├── hangul_speller.dart         # Unicode Mathematical Syllable Deconstructor
│   │   │   └── korean_grammar_engine.dart  # Unconstrained SOV Engine, Batchim Detector, & Conjugator
│   │   └── services/
│   │       └── audio_tts_service.dart      # Singleton Android Native Offline TTS (Normal & Kura-kura)
│   ├── data/
│   │   ├── database/
│   │   │   ├── database_helper.dart        # SQLite Singleton, 1200+ Auto-Migration, & Checklist CRUD
│   │   │   └── memorized_seed_data.dart    # 90 data awal checklist hafalan 9 agenda harian
│   │   ├── models/
│   │   │   ├── dictionary_item.dart        # Model entitas kamus trilingual dengan properti category
│   │   │   ├── exam_model.dart             # Model paket ujian, soal kuis, & riwayat nilai
│   │   │   ├── memorized_item.dart         # Model entitas checklist hafalan tersimpan permanen
│   │   │   └── standard_practice_model.dart# Model kurikulum standar EPS-TOPIK (Level, Bab, Dialog, Soal)
│   │   └── repositories/
│   │       └── standard_practice_repository.dart # Repositori 7 level kurikulum resmi HRD Korea Jilid 1 & 2
│   ├── presentation/
│   │   ├── pages/
│   │   │   ├── home_navigation_screen.dart       # Material 3 NavigationBar (6 Destinasi), Drawer, & Theme Switcher
│   │   │   ├── tab_translator_grammar.dart       # Menu 1: Translator & SOV Parser tanpa batasan + Tombol Enter
│   │   │   ├── tab_dictionary.dart               # Menu 2: Kamus Trilingual Komprehensif (1.250+ entri)
│   │   │   ├── custom_self_intro_page.dart       # Menu 3: Studio Kustom Perkenalan Diri (Nama, Asal, Sekolah, Tujuan)
│   │   │   ├── tab_memorized_checklist.dart       # Menu 4: Checklist Hafalan Harian 9 Agenda
│   │   │   ├── tab_standard_practice.dart        # Menu 5: Kurikulum Standar EPS-TOPIK 7 Level
│   │   │   ├── standard_chapter_detail_page.dart # Layar Detail Bab: Dialog, Kosakata, & Latihan Soal
│   │   │   ├── tab_exam_levels.dart              # Menu 6: Daftar Paket Level Ujian 1 - 4
│   │   │   └── quiz_screen.dart                  # Layar Kuis Ujian dengan pembahasan Indonesia & Korea
│   │   └── widgets/
│   │       ├── grammar_breakdown_card.dart       # Kartu analisis SOV & tingkat kesopanan
│   │       ├── korean_spelling_card.dart         # Kartu formula ejaan [초성 + 중성 + 종성]
│   │       ├── tts_speaker_button.dart           # Tombol audio normal (0.45x)
│   │       ├── turtle_icon.dart                  # Custom painter vector logo kura-kura
│   │       └── turtle_slow_button.dart           # Tombol audio kura-kura lambat (0.22x)
│   └── main.dart                                 # Inisialisasi aplikasi, database pre-init, & tema
├── test/
│   └── widget_test.dart                          # Unit test suite lengkap (18 / 18 passed 100%)
├── tool/
│   ├── build_db.py                               # Compiler offline SQLite database dari init.sql
│   ├── build_massive_dictionary.py               # Generator kamus komprehensif 1.250+ kosakata
│   └── generate_practice_repo.py                 # Generator kurikulum standar repositori EPS-TOPIK
└── pubspec.yaml                                  # Dependensi esensial (sqflite, flutter_tts, path, dll.)
```

---

## Cara Menjalankan & Membangun

### 1. Prasyarat Lingkungan
- Flutter SDK (v3.13+ / Dart 3.0+)
- Android Studio / Android SDK (API level 21+)

### 2. Mengambil Dependensi
```bash
flutter pub get
```

### 3. Menjalankan Unit Test (100% Passed)
```bash
flutter test
```
*Menguji 18 skenario: formula matematika `HangulSpeller`, deteksi batchim fonetik, aturan partikel 'ㄹ', konjugasi verba, pemetaan SOV situasi baru, model serialisasi, repositori kurikulum standar EPS-TOPIK 7 level, serta penanganan null-safety defensif paket ujian.*

### 4. Membangun Berkas APK
```bash
flutter build apk --debug
```
*Hasil berkas APK siap pakai tersedia di:* `build/app/outputs/flutter-apk/app-debug.apk`.

---

## Jaminan Privasi & Efisiensi Energi
- **Pengecualian Berkas Dokumen Besar**: Folder `dokumen/` (PDF Jilid 1 & 2 serta 327 berkas audio MP3 dengan ukuran ~800MB) telah dimasukkan ke dalam `.gitignore` sehingga tidak ikut terunggah ke repositori git. Seluruh materi esensial telah diintegrasikan langsung ke dalam struktur data aplikasi dengan ukuran APK yang tetap sangat ringan (<35 MB).
- **Nol Akses Internet**: Bebas pelacakan, aman tanpa pengiriman data pribadi ke server eksternal mana pun.
- **Konsumsi Daya Minimum**: Operasi fonetik murni formula bitwise & aljabar Unicode tanpa beban pemrosesan berat.
- **Offline Text-To-Speech**: Memanfaatkan pustaka sintesis ucapan lokal bawaan Android dengan dukungan kecepatan lambat kura-kura untuk artikulasi maksimal.
