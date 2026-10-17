# Trilingual Korean Offline Master (한국어 • Indonesia • English)

Aplikasi Android edukasi bahasa Korea modern, ringan, dan **100% FULL OFFLINE (Local-Only Architecture)**. Seluruh logika data (*embedded local backend*), database SQLite berindeks, pemroses tata bahasa fonetik, dan antarmuka *frontend* terbungkus mandiri di dalam satu paket APK tanpa server cloud atau API eksternal. Performa sangat ringan, dingin di prosesor, dan hemat baterai.

---

## Fitur Utama & Keunggulan

### 1. Embedded Local Backend & Business Logic (Pure Dart & SQLite)
* **Deterministic Rule-Based Grammar Engine**:
  - **Pemetaan Struktur Otomatis**: Mentransformasi pola kalimat **S-V-O** (Indonesia/Inggris) menjadi struktur **S-O-V** (Korea) secara alami.
  - **Injeksi Partikel Cerdas (Deteksi Batchim Otomatis)**:
    - **Topik**: `은` (ada batchim) / `는` (vokal).
    - **Subjek**: `이` (ada batchim) / `가` (vokal).
    - **Objek**: `을` (ada batchim) / `를` (vokal).
    - **Keterangan Tempat**: `에서` (lokasi aktivitas aktif) / `에` (tujuan pergerakan/keberadaan statis).
    - **Keterangan Sarana & Arah**: `으로` (konsonan biasa) / `로` (vokal atau konsonan akhir 'ㄹ' / *Rieul batchim rule*).
  - **Predicate Conjugator**: Mengonjugasikan akar kata verba/adjektiva dasar secara otomatis ke:
    - *Informal Polite* (`-아요` / `-어요` / `-해요`)
    - *Formal Polite* (`-ㅂ니다` / `-습니다`)
    - *Bentuk Lampau* (`-았어요` / `-었어요` / `-했어요`)
    - *Bentuk Rencana/Masa Depan* (`-(으)ㄹ 거예요`)
    - *Bentuk Kamus Dasar* (`-다`)

* **Unicode Mathematical Deconstructor (`HangulSpeller`)**:
  - Mengurai suku kata Hangul (`0xAC00` – `0xD7A3`) menggunakan rumus matematika Unicode murni dengan memori 0 KB.
  - Memecah karakter menjadi **Choseong (초성)**, **Jungseong (중성)**, dan **Jongseong/Batchim (종성/받침)**.
  - Menghasilkan visualisasi formula: `"[ㄱ + ㅏ + ㅁ = 감] [ㅅ + ㅏ = 사]"`.

* **Embedded Storage Engine (SQLite via `sqflite`)**:
  - Database terindeks `assets/db/dictionary.db` di-bundle langsung di dalam APK.
  - Mekanisme **`DatabaseHelper` (Singleton)** menyalin database aset ke direktori internal perangkat saat pertama kali aplikasi dijalankan.
  - Tersedia skrip DDL SQL inisialisasi dan *seed data* di `assets/sql/init.sql`.

* **Offline Audio Engine (`flutter_tts`)**:
  - Mengintegrasikan mesin *Text-To-Speech* lokal bawaan OS Android untuk memutar audio bahasa Korea (`ko-KR`) dan Inggris (`en-US`) secara *offline*.
  - Dilengkapi animasi speaker berdenyut (*pulse effect*) saat audio sedang diputar.

---

### 2. Local Frontend & Desain UI/UX (Modern Material 3)
* **Skema Warna Elegan**: Mengadopsi palet *Deep Indigo / Slate* dengan aksen *Soft Mint*, *Cyan*, dan *Coral*.
* **Dark Mode & Light Mode**: Mendukung peralihan tema terang dan gelap dengan transisi mulus.
* **Tiga Menu Navigasi Utama (NavigationBar M3)**:
  1. **Parser SOV (Halaman 1)**:
     - Search & input field modern dengan tombol bersihkan instan.
     - Template kalimat cepat (*quick-fill chips*): "Saya makan nasi", "Budi membaca buku di perpustakaan", dll.
     - *Interactive Breakdown Card*: Tag/badge penanda warna untuk Subjek (Biru), Tempat (Teal), Objek (Amber), Predikat (Ungu), dan Partikel (Cyan).
     - *Formality Switcher*: Beralih seketika antara ragam informal, formal, lampau, masa depan, dan kamus.
     - *Kartu Dekonstruksi Fonetik HangulSpeller*.
  2. **Kamus Trilingual (Halaman 2)**:
     - Pencarian trilingual instan dengan *debouncing* (Hangul, Romanisasi, Bahasa Indonesia, Bahasa Inggris).
     - Filter kategori POS (*Part of Speech*): Noun, Verb, Adjective, Particle, Phrase, Pronoun.
     - *Modal Bottom Sheet Detail*: Menampilkan dekonstruksi suku kata lengkap dan tabel konjugasi otomatis untuk verba/adjektiva.
  3. **Latihan Ujian Bertingkat (Halaman 3)**:
     - Paket Level 1 (Dasar Hangeul & Partikel) s.d. Level 4 (TOPIK I Mastery).
     - Indikator skor terbaik dan jumlah soal.
     - Layar kuis interaktif dengan *visual feedback* instan (border hijau lembut saat benar, border merah lembut saat salah).
     - Kartu pembahasan dwibahasa (Indonesia & Inggris) di setiap akhir soal.
     - Penyimpanan skor riwayat latihan secara offline di SQLite.

---

## Struktur Proyek

```text
mobile_korea_id/
├── assets/
│   ├── db/
│   │   └── dictionary.db          # Binary SQLite database bundled di APK
│   └── sql/
│       └── init.sql               # Skrip DDL tabel & 117+ data kosakata, paket level, dan soal ujian
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_theme.dart     # Design tokens Material 3, skema warna, typography, card shadows
│   │   ├── engine/
│   │   │   ├── hangul_speller.dart         # Unicode Mathematical Syllable Deconstructor
│   │   │   └── korean_grammar_engine.dart  # Rule-Based SOV Mapper, Batchim Detector, & Conjugator
│   │   └── services/
│   │       └── audio_tts_service.dart      # Singleton Android Native Offline TTS
│   ├── data/
│   │   ├── database/
│   │   │   └── database_helper.dart        # SQLite Singleton & Safe Asset Copy Manager
│   │   └── models/
│   │       ├── dictionary_item.dart        # Model entitas kamus trilingual
│   │       └── exam_model.dart             # Model paket ujian, soal kuis, & riwayat nilai
│   ├── presentation/
│   │   ├── pages/
│   │   │   ├── home_navigation_screen.dart # Material 3 NavigationBar & Theme Switcher
│   │   │   ├── tab_translator_grammar.dart # Halaman 1: Translator & SOV Parser
│   │   │   ├── tab_dictionary.dart         # Halaman 2: Kamus Trilingual dengan Debouncing
│   │   │   ├── tab_exam_levels.dart        # Halaman 3: Daftar Paket Level Ujian 1 - 4
│   │   │   └── quiz_screen.dart            # Layar Kuis Ujian Interaktif & Penjelasan Dwibahasa
│   │   └── widgets/
│   │       ├── grammar_breakdown_card.dart # Kartu analisis SOV & tingkat kesopanan
│   │       ├── korean_spelling_card.dart   # Kartu formula ejaan [초성 + 중성 + 종성]
│   │       └── tts_speaker_button.dart     # Tombol audio dengan animasi denyut
│   └── main.dart                          # Inisialisasi aplikasi, database pre-init, & tema
├── test/
│   └── widget_test.dart                   # Unit test engine fonetik & tata bahasa
└── pubspec.yaml                           # Dependensi esensial (sqflite, flutter_tts, path, dll.)
```

---

## Skema Database SQLite (`dictionary.db`)

1. **`dictionary`**:
   - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
   - `indonesian`: TEXT (Kata/makna bahasa Indonesia)
   - `english`: TEXT (Kata/makna bahasa Inggris)
   - `korean_hangul`: TEXT (Aksara Hangul Korea)
   - `korean_roman`: TEXT (Romanisasi baku Korea)
   - `pos`: TEXT (Part of Speech: Noun, Verb, Adjective, Particle, Phrase, Pronoun)
   - `sentence_pattern`: TEXT (S, O, Place, V, Instrument)
   - `base_verb`: TEXT (Akar kata untuk konjugasi)
   *Index*: `idx_dict_indonesian`, `idx_dict_english`, `idx_dict_korean_hangul`, `idx_dict_pos`

2. **`exam_packages`**:
   - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
   - `title`: TEXT (Nama paket, misal: "Level 1: Dasar Hangeul & Partikel")
   - `level`: INTEGER (1 s.d. 4)
   - `total_questions`: INTEGER

3. **`exam_questions`**:
   - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
   - `package_id`: INTEGER (Relasi ke `exam_packages`)
   - `type`: TEXT (Jenis soal: partikel, struktur SOV, konjugasi, dll.)
   - `question`: TEXT (Teks pertanyaan)
   - `hangul_audio_text`: TEXT (Teks pelafalan TTS native)
   - `option_a`, `option_b`, `option_c`, `option_d`: TEXT
   - `correct_answer`: TEXT ('A', 'B', 'C', 'D')
   - `explanation_id`: TEXT (Penjelasan tata bahasa bahasa Indonesia)
   - `explanation_en`: TEXT (Penjelasan tata bahasa bahasa Inggris)
   *Index*: `idx_questions_package`

4. **`user_quiz_history`**:
   - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
   - `package_id`: INTEGER
   - `score`: INTEGER
   - `total_questions`: INTEGER
   - `percentage`: REAL
   - `completed_at`: TEXT

---

## Cara Menjalankan Aplikasi

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
*Menguji formula matematika `HangulSpeller` [ㄱ+ㅏ+ㅁ=감], deteksi batchim fonetik, konjugasi verba, dan parser SOV.*

### 4. Menjalankan Aplikasi di Emulator / Perangkat Android Fisik
```bash
flutter run
```

### 5. Membangun Berkas APK Siap Rilis (Production Ready)
```bash
flutter build apk --release
```
*Hasil berkas APK siap pakai akan tersedia di:* `build/app/outputs/flutter-apk/app-release.apk`.

---

## Jaminan Privasi & Efisiensi Energi
- **Nol Akses Internet**: Bebas pelacakan, aman tanpa pengiriman data pribadi.
- **Konsumsi Daya Minimum**: Operasi fonetik murni formula bitwise & aljabar Unicode tanpa *regex* berat atau alokasi *garbage collection* berlebih.
- **Offline Text-To-Speech**: Memanfaatkan pustaka sintesis ucapan lokal bawaan Android.
