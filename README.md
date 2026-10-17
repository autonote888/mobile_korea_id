# Trilingual Korean Offline Master (한국어 • Indonesia • English)

Aplikasi Android edukasi bahasa Korea modern, ringan, dan **100% FULL OFFLINE (Local-Only Architecture)**. Seluruh logika data (*embedded local backend*), database SQLite berindeks, pemroses tata bahasa fonetik, kurikulum standar EPS-TOPIK 7 level, dan antarmuka *frontend* terbungkus mandiri di dalam satu paket APK tanpa server cloud atau API eksternal. Performa sangat ringan, dingin di prosesor, dan hemat baterai.

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
  - Romanisasi fonetik otomatis untuk suku kata dan kata utuh.

* **Embedded Storage Engine (SQLite via `sqflite`)**:
  - Database terindeks `assets/db/dictionary.db` (versi 2) di-bundle langsung di dalam APK.
  - Berisi **237+ entri kosakata & frasa trilingual** yang dibagi ke dalam **12 kategori kegiatan tematik**.
  - Mekanisme **`DatabaseHelper` (Singleton)** mengelola salinan database aman dan *auto-migration* mandiri.
  - Skrip DDL SQL inisialisasi dan *seed data* lengkap di `assets/sql/init.sql`.

* **Offline Dual-Speed Audio Engine (`flutter_tts`)**:
  - Mengintegrasikan sintesis ucapan lokal bawaan Android untuk bahasa Korea (`ko-KR`) dan Inggris (`en-US`).
  - **Tombol Normal Speaker**: Memutar audio pelafalan alami dengan kecepatan wajar (0.45x).
  - **Tombol Kura-kura (Turtle Slow Mode)**: Memutar audio pelafalan lambat (0.22x) dengan animasi detak halus agar pembelajar dapat menangkap artikulasi konsonan akhir (*batchim*) secara presisi.

---

### 2. Menu Latihan Kurikulum Standar EPS-TOPIK (Berdasarkan Sumber Dokumen)

Materi latihan terstruktur dari buku standar resmi HRD Korea: **Jilid 1 (Bab 1 - 30)** dan **Jilid 2 (Bab 31 - 60)** yang didukung **Audio Track 001 s.d. 327**, diorganisasikan ke dalam 7 tingkatan pembelajaran progresif:

1. **Level 1: Persiapan & Kehidupan Dasar (Bab 1 - 8 | Jilid 1 | Track 001 - 067)**:
   - Alfabet Hangeul, salam sapaan, perkenalan diri & profesi (`입니다`, `은/는`).
   - Perlengkapan harian & kantor (`이에요/예요`), lokasi fasilitas (`이/가 있어요/없어요`, `에`).
   - Aktivitas harian (`-아요/어요`, `을/를`), hari & tanggal (`-았/었-`), jam kerja (`-(스)ㅂ니다`), empat musim, dan keluarga (`-(으)시-`).

2. **Level 2: Komunikasi & Transaksi Harian (Bab 9 - 15 | Jilid 1 | Track 068 - 102)**:
   - Pemesanan makanan restoran (`주세요`, satuan porsi/mangkuk), belanja barang & diskon (`-아/어 주세요`, harga Won).
   - Pekerjaan rumah & pemilahan sampah Jongnyangje (`-아야 되다`), transportasi subway & bus (`(으)로`, transfer).
   - Rencana akhir pekan (`-(으)ㄹ 거예요`), petunjuk arah jalan (`(으)로 방향`), dan ragam pakaian/sepatu (`-고 있다`).

3. **Level 3: Kehidupan Sosial & Layanan Publik (Bab 16 - 25 | Jilid 1 | Track 103 - 152)**:
   - Mencari kamar kos studio One-room (`-고 싶다`, uang jaminan bojeunggeum & sewa bulanan wolse), liburan wisata.
   - Hobi & olahraga (`-는 것`), resep masakan Korea (`-아/어 보다`), aplikasi internet smartphone (`-고 있다`).
   - Rumah sakit & poli klinik (`-(으)면`), apotek & cara minum obat (`-(으)ㄴ 후에`), bank & transfer uang luar negeri (`-(으)려고 하다`), dan pusat bantuan pekerja asing.

4. **Level 4: Budaya Korea & Etika Sosial (Bab 26 - 30 | Jilid 1 | Track 153 - 177)**:
   - Budaya tempat tinggal Ondol & etika meja makan orang tua (`-아도 되다`), peringatan hari nasional.
   - Hari raya Seollal & Chuseok (`-고 나서`, sup kue beras tteokguk, sungkem sebae), etika publik (`-(으)면 안 되다`), dan gelombang budaya Hallyu.

5. **Level 5: Dunia Kerja & Hubungan Pabrik (Bab 31 - 40 | Jilid 2 | Track 178 - 227)**:
   - Seragam kerja pabrik & kerapian (`-아/어 보이다`, resleting/kancing), fasilitas asrama & kantin.
   - Hubungan rekan kerja (`-는 편이다`), makan malam bersama hoesik, pencegahan pelecehan tempat kerja.
   - Manajemen gudang, pengepakan barang, pengoperasian mesin industri, perakitan komponen, pemotongan logam & pengelasan (`-기 전에`, gerinda, kacamata pelindung), dan cetak plastik karet.

6. **Level 6: Sektor Industri & Keselamatan K3 (Bab 41 - 56 | Jilid 2 | Track 228 - 307)**:
   - Industri tekstil & pewarnaan kain, pembuatan mebel kayu, konstruksi bangunan & besi beton (`-(으)ㄹ 텐데`, tali pengaman anti-jatuh).
   - Teknik sipil gorong-gorong, pertanian smart farm, peternakan hewan, perikanan laut & jaring ikan (`-는 동안에`, rompi pelampung).
   - Galangan kapal, tambang mineral, kehutanan, perhotelan, tata boga kuliner.
   - Rambu keselamatan kerja K3 (`-아 있다`, tegangan listrik, dilarang merokok, api), SOP keselamatan, Alat Pelindung Diri (APD), dan P3K tanggap darurat kebakaran.

7. **Level 7: Hukum Kerja & Prosedur EPS-TOPIK (Bab 57 - 60 | Jilid 2 | Track 308 - 327)**:
   - Sistem Izin Kerja Korea (EPS / E-9) dan masa tinggal hingga 4 tahun 10 bulan (`-게 되다`).
   - Standar Kontrak Kerja Baku & rincian slip gaji (`뿐만 아니라`, `-(으)면 좋겠다`).
   - Keimigrasian, pendaftaran warga asing ARC, perpanjangan visa (`-더라도`).
   - Asuransi pekerja asing: asuransi kepulangan chulguk mangi, asuransi tiket pulang, dan asuransi kecelakaan kerja industri Sanjae Boheom (`-(으)려면`).

---

### 3. Pembagian Kategori Belajar Kamus Trilingual (12 Aktivitas Tematik)

1. **Perkenalan Diri (자기소개)**:
   - *Umum*: Salam kenal pertama kali (`처음 뵙겠습니다`), nama (`제 이름은 ... 입니다`), mohon bimbingan (`잘 부탁드립니다`).
   - *Pendidikan*: Status mahasiswa (`저는 대학생입니다`), jurusan (`제 전공은 ... 입니다`), kelulusan (`대학교를 졸업했습니다`).
   - *Asal*: Asal negara/daerah (`저는 인도네시아에서 왔습니다`), orang asing (`외국인`), kampung halaman (`고향`).
   - *Tujuan*: Maksud kedatangan untuk belajar (`한국어를 배우러 왔습니다`), bekerja (`취업을 위해 왔습니다`), berwisata (`여행하러 왔습니다`), tujuan (`제 목표는 ... 입니다`).

2. **Kata Ganti & Hubungan Sosial (대명사 & 사회관계)**:
   - *Saya / Aku*: `저` (sopan/merendah), `나` (akrab/kasual).
   - *Kamu / Anda*: `당신` (sopan/formal), `너` (akrab), `여러분` (hadirin sekalian), `너희` (kalian).
   - *Kami / Kita*: `우리` (umum), `저희` (sopan/merendahkan diri).
   - *Bersama / Bareng*: `함께` (formal), `같이` (percakapan harian).
   - *Sendiri / Mandiri*: `혼자` (sendirian), `스스로` (secara mandiri).
   - *Hubungan*: Teman (`친구`), keluarga (`가족`), orang tua (`부모님`), saudara (`형`, `오빠`, `누나`, `언니`, `동생`).

3. **Belanja & Supermarket (쇼핑 & 마트)**:
   - Supermarket (`마트`), minimarket 24 jam (`편의점`), kasir (`계산대`).
   - Menanyakan harga (`얼마예요?`), struk/nota (`영수증 주세요`), kantong plastik (`봉투 필요하세요?`).
   - Pembayaran kartu (`카드로 결제할게요`), uang tunai (`현금`), diskon (`할인`, `깎아 주세요`), refund (`환불`).

4. **Waktu Tidur & Rutinitas Harian (수면 & 일상)**:
   - Tidur (`자다`), tidur honorifik (`주무시다`), selamat tidur sopan (`안녕히 주무세요`), selamat tidur santai (`잘 자요`).
   - Mimpi indah (`좋은 꿈 꿔요`), mimpi (`꿈`), mengantuk (`졸려요`), bangun (`일어나다`), mandi (`샤워하다`), lelah (`피곤하다`).

5. **Arah & Navigasi di Jalan (길 찾기 & 길거리)**:
   - Tersesat (`실례합니다, 길을 잃었어요`), menanyakan letak toilet (`화장실이 어디에 있어요?`), jarak/durasi (`여기서 얼마나 걸려요?`).
   - Arah: Kanan (`오른쪽`), kiri (`왼쪽`), lurus terus (`직진`, `곧장 가세요`), seberang jalan (`건너편`), dekat (`가깝다`), jauh (`멀다`).

6. **Restoran & Makanan (식당 & 음식)**:
   - Memesan (`여기요, 주문할게요`), minta menu (`메뉴판`), minta air (`물 좀 주세요`), minta sendok/sumpit (`수저 주세요`).
   - Minta nota/bon (`계산해 주세요`), ungkapan sebelum makan (`잘 먹겠습니다`), sesudah makan (`잘 먹었습니다`).
   - Rasa: Enak (`맛있다`), pedas (`맵다`), manis (`달다`), asin (`짜다`), tawar (`싱겁다`).

7. **Transportasi & Perjalanan (교통 & 이동)**:
   - Subway (`지하철`), stasiun (`역`), bus (`버스`), halte (`정류장`), taksi (`택시`), bandara (`공항`).
   - Naik kendaraan (`타다`), turun (`내리다`), transit/transfer (`갈아타다`), kartu transportasi (`교통카드`).

8. **Kesehatan & Keadaan Darurat (병원 & 응급)**:
   - Minta tolong (`도와주세요!`), rumah sakit (`병원`), apotek (`약국`), obat (`약`), sakit (`아파요`).
   - Sakit kepala (`두통`), flu (`감기`), demam (`열`), darurat ambulans (`119`), polisi (`112`).

9. **Dunia Kerja & Belajar (직장 & 학교)**:
   - Kantor (`회사`), berangkat kerja (`출근하다`), pulang kerja (`퇴근하다`), rapat (`회의`), berkas (`서류`), lembur (`야근`).
   - Bekerja (`일하다`), belajar (`공부하다`), mengajar (`가르치다`), komputer (`컴퓨터`), ujian (`시험`).

10. **Emosi, Cuaca & Waktu (감정, 날씨 & 시간)**:
    - Senang (`기쁘다`), sedih (`슬프다`), lapar (`배고프다`), kenyang (`배부르다`).
    - Cuaca cerah (`맑다`), hujan (`비가 오다`), salju (`눈이 오다`), hari ini (`오늘`), besok (`내일`), sekarang (`지금`).

11. **Percakapan & Ungkapan Umum (인사 & 기본 표현)**:
    - Salam (`안녕하세요`), terima kasih (`감사합니다`), maaf (`죄송합니다`), ya (`네`), tidak (`아니요`).

12. **Tata Bahasa & Partikel (조사)**:
    - Partikel penanda topik, subjek, objek, lokasi, waktu, dan sarana/alat.

---

### 4. Empat Menu Navigasi Utama (Material 3 NavigationBar)
1. **Parser SOV (Menu 1)**:
   - Search & input field modern dengan tombol bersihkan instan.
   - Template kalimat cepat (*quick-fill chips*): "Saya makan roti", "Saya pergi ke supermarket", "Mahasiswa belajar bahasa Korea", dll.
   - *Interactive Breakdown Card*: Menampilkan urutan Arti -> Cara Baca -> Aksara Hangul dengan tombol audio kura-kura dan normal.
   - *Formality Switcher*: Beralih seketika antara ragam informal, formal, lampau, masa depan, dan kamus.
2. **Kamus Trilingual (Menu 2)**:
   - Pencarian trilingual instan dengan *debouncing* 250ms.
   - Filter ganda: Kategori Aktivitas Tematik (12 kategori) dan Kelas Kata POS (8 jenis).
   - Format kartu: **Arti (Bahasa Indonesia)** -> **Bacaan / Romanisasi [koreanRoman]** -> **Aksara Hangul** -> **Tombol Kura-kura & Speaker**.
   - **100% Bebas Overflow**: Seluruh baris teks dibatasi secara elastis dengan pembatas dinamis (`maxLines: 2`, `TextOverflow.ellipsis`).
   - *Modal Bottom Sheet Detail*: Menampilkan detail lengkap, tabel konjugasi otomatis, dan analisis suku kata Unicode.
3. **Latihan Kurikulum Standar (Menu 3)**:
   - Kurikulum resmi HRD Korea Jilid 1 & Jilid 2 (Bab 1 s.d. 60 + Audio Track 001 s.d. 327).
   - Pengelompokan 7 tingkatan pembelajaran progresif (Level 1 s.d. Level 7).
   - Pencarian instan per nomor bab, aksara Korea, atau topik pekerjaan.
   - Layar detail bab interaktif dengan 3 tab:
     - **Percakapan (대화)**: Teks dialog lengkap antar tokoh penutur asli Korea dengan audio TTS normal dan lambat kura-kura per kalimat.
     - **Kosakata & Tata Bahasa (어휘 & 문법)**: Daftar kosakata target dan pola tata bahasa beserta contoh kalimat aplikatif.
     - **Latihan Soal (연습 문제)**: Kuis pilihan ganda interaktif dengan koreksi jawaban langsung dan pembahasan dwibahasa (Indonesia & Korea).
4. **Latihan Ujian Bertingkat (Menu 4)**:
   - Paket Level 1 diperkaya menjadi **15 Soal Komprehensif** berdasarkan tren ujian TOPIK I 2 tahun terakhir.
   - Pembahasan detail dwibahasa di setiap akhir soal:
     - **Petunjuk Penyelesaian (Bahasa Indonesia)**: Penjelasan tata bahasa, analisis partikel, dan kunci jawaban.
     - **핵심 해설 & 힌트 (한국어)**: Penjelasan inti dalam bahasa Korea dilengkapi tombol audio TTS kura-kura dan normal.
   - Paket Level 2 (Struktur SOV & Arah), Level 3 (Konjugasi Sopan & Lampau), dan Level 4 (TOPIK I Mastery).

---

## Struktur Proyek

```text
mobile_korea_id/
├── .gitignore                     # Mengecualikan dokumen/ (PDF & MP3 ~800MB) dan scratch/ dari git
├── android/
│   └── .gitignore                 # Mengecualikan dokumen/ pada level android
├── assets/
│   ├── db/
│   │   └── dictionary.db          # Binary SQLite database terindeks (237 kosakata & 15 soal Level 1)
│   └── sql/
│       └── init.sql               # Skrip DDL tabel & data seed kamus 12 kategori dan soal ujian
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_theme.dart     # Design tokens Material 3, skema warna, typography, card shadows
│   │   ├── engine/
│   │   │   ├── hangul_speller.dart         # Unicode Mathematical Syllable Deconstructor
│   │   │   └── korean_grammar_engine.dart  # Rule-Based SOV Mapper, Batchim Detector, & Conjugator
│   │   └── services/
│   │       └── audio_tts_service.dart      # Singleton Android Native Offline TTS (Normal & Kura-kura)
│   ├── data/
│   │   ├── database/
│   │   │   └── database_helper.dart        # SQLite Singleton, Category Filter, & V2 Migration Manager
│   │   ├── models/
│   │   │   ├── dictionary_item.dart        # Model entitas kamus trilingual dengan properti category
│   │   │   ├── exam_model.dart             # Model paket ujian, soal kuis, & riwayat nilai
│   │   │   └── standard_practice_model.dart# Model kurikulum standar EPS-TOPIK (Level, Bab, Dialog, Soal)
│   │   └── repositories/
│   │       └── standard_practice_repository.dart # Repositori 7 level kurikulum resmi HRD Korea Jilid 1 & 2
│   ├── presentation/
│   │   ├── pages/
│   │   │   ├── home_navigation_screen.dart       # Material 3 NavigationBar (4 Destinasi) & Theme Switcher
│   │   │   ├── tab_translator_grammar.dart       # Menu 1: Translator & SOV Parser dengan template baru
│   │   │   ├── tab_dictionary.dart               # Menu 2: Kamus Trilingual dengan filter aktivitas
│   │   │   ├── tab_standard_practice.dart        # Menu 3: Kurikulum Standar EPS-TOPIK 7 Level
│   │   │   ├── standard_chapter_detail_page.dart # Layar Detail Bab: Dialog, Kosakata, & Latihan Soal
│   │   │   ├── tab_exam_levels.dart              # Menu 4: Daftar Paket Level Ujian 1 - 4
│   │   │   └── quiz_screen.dart                  # Layar Kuis Ujian dengan pembahasan Indonesia & Korea
│   │   └── widgets/
│   │       ├── grammar_breakdown_card.dart       # Kartu analisis SOV & tingkat kesopanan
│   │       ├── korean_spelling_card.dart         # Kartu formula ejaan [초성 + 중성 + 종성]
│   │       ├── tts_speaker_button.dart           # Tombol audio normal (0.45x)
│   │       ├── turtle_icon.dart                  # Custom painter vector logo kura-kura
│   │       └── turtle_slow_button.dart           # Tombol audio kura-kura lambat (0.22x)
│   └── main.dart                                 # Inisialisasi aplikasi, database pre-init, & tema
├── test/
│   └── widget_test.dart                          # Unit test suite lengkap (16 / 16 passed 100%)
├── tool/
│   ├── build_db.py                               # Compiler offline SQLite database dari init.sql
│   └── generate_practice_repo.py                 # Generator kurikulum standar repositori EPS-TOPIK
└── pubspec.yaml                                  # Dependensi esensial (sqflite, flutter_tts, path, dll.)
```

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
*Menguji 16 skenario: formula matematika `HangulSpeller`, deteksi batchim fonetik, aturan partikel 'ㄹ', konjugasi verba, pemetaan SOV situasi baru, model serialisasi, serta repositori kurikulum standar EPS-TOPIK 7 level.*

### 4. Membangun Berkas APK
```bash
flutter build apk --debug
```
*Hasil berkas APK siap pakai tersedia di:* `build/app/outputs/flutter-apk/app-debug.apk`.

---

## Jaminan Privasi & Efisiensi Energi
- **Pengecualian Berkas Dokumen Besar**: Folder `dokumen/` (PDF Jilid 1 & 2 serta 327 berkas audio MP3 dengan ukuran ~800MB) telah dimasukkan ke dalam `.gitignore` sehingga tidak ikut terunggah ke repositori git. Seluruh materi esensial telah diintegrasikan langsung ke dalam struktur data aplikasi dengan ukuran APK yang tetap sangat ringan (<35 MB).
- **Nol Akses Internet**: Bebas pelacakan, aman tanpa pengiriman data pribadi.
- **Konsumsi Daya Minimum**: Operasi fonetik murni formula bitwise & aljabar Unicode tanpa regex berat atau alokasi garbage collection berlebih.
- **Offline Text-To-Speech**: Memanfaatkan pustaka sintesis ucapan lokal bawaan Android dengan dukungan kecepatan lambat kura-kura untuk artikulasi maksimal.
