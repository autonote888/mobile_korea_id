-- ================================================================
-- TRILINGUAL KOREAN OFFLINE MASTER - SQL INITIALIZATION SCHEMA V2
-- ================================================================

-- 1. Table: dictionary
CREATE TABLE IF NOT EXISTS dictionary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    indonesian TEXT NOT NULL,
    english TEXT NOT NULL,
    korean_hangul TEXT NOT NULL,
    korean_roman TEXT NOT NULL,
    pos TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Umum',
    sentence_pattern TEXT,
    base_verb TEXT
);

CREATE INDEX IF NOT EXISTS idx_dict_indonesian ON dictionary(indonesian);
CREATE INDEX IF NOT EXISTS idx_dict_english ON dictionary(english);
CREATE INDEX IF NOT EXISTS idx_dict_korean_hangul ON dictionary(korean_hangul);
CREATE INDEX IF NOT EXISTS idx_dict_pos ON dictionary(pos);
CREATE INDEX IF NOT EXISTS idx_dict_category ON dictionary(category);

-- 2. Table: exam_packages
CREATE TABLE IF NOT EXISTS exam_packages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    level INTEGER NOT NULL,
    total_questions INTEGER NOT NULL
);

-- 3. Table: exam_questions
CREATE TABLE IF NOT EXISTS exam_questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    package_id INTEGER NOT NULL,
    type TEXT NOT NULL,
    question TEXT NOT NULL,
    hangul_audio_text TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_answer TEXT NOT NULL,
    explanation_id TEXT NOT NULL,
    explanation_en TEXT NOT NULL,
    FOREIGN KEY(package_id) REFERENCES exam_packages(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_questions_package ON exam_questions(package_id);

-- 4. Table: user_quiz_history (Local offline progress)
CREATE TABLE IF NOT EXISTS user_quiz_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    package_id INTEGER NOT NULL,
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    percentage REAL NOT NULL,
    completed_at TEXT NOT NULL
);

-- ================================================================
-- SEED DATA: ENRICHED TRILINGUAL DICTIONARY
-- ================================================================

-- ----------------------------------------------------------------
-- 1. KATEGORI: PERKENALAN DIRI (자기소개 - JAGI SOGAE)
-- Termasuk umum, pendidikan, asal negara/kota, dan tujuan kedatangan
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Salam kenal (Pertama kali bertemu)', 'Nice to meet you (First meeting)', '처음 뵙겠습니다', 'cheoeum boepgetseumnida', 'Phrase', 'Perkenalan Diri', 'Greeting', NULL),
('Nama saya adalah...', 'My name is...', '제 이름은 ... 입니다', 'je ireumeun ... imnida', 'Phrase', 'Perkenalan Diri', 'Identity', NULL),
('Mohon bantuannya / kerja samanya', 'Please look favorably upon me', '잘 부탁드립니다', 'jal butakdeurimnida', 'Phrase', 'Perkenalan Diri', 'Courtesy', NULL),
('Nama', 'Name', '이름', 'ireum', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Usia / Umur', 'Age', '나이', 'nai', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Profesi / Pekerjaan', 'Occupation / Job', '직업', 'jigeop', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Saya berasal dari Indonesia', 'I came from Indonesia', '저는 인도네시아에서 왔습니다', 'jeoneun indonesia-eseo watseumnida', 'Phrase', 'Perkenalan Diri', 'Origin', NULL),
('Negara Asal / Kampung Halaman', 'Hometown / Native Country', '고향', 'gohyang', 'Noun', 'Perkenalan Diri', 'Place', NULL),
('Orang Indonesia', 'Indonesian Person', '인도네시아 사람', 'indonesia saram', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Orang Korea', 'Korean Person', '한국 사람', 'hanguk saram', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Warga Negara Asing', 'Foreigner', '외국인', 'oegugin', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Saya adalah seorang mahasiswa', 'I am a university student', '저는 대학생입니다', 'jeoneun daehaksaeng-imnida', 'Phrase', 'Perkenalan Diri', 'Education', NULL),
('Saya lulus dari perguruan tinggi...', 'I graduated from university...', '... 대학교를 졸업했습니다', '... daehakgyoreul joreophaetseumnida', 'Phrase', 'Perkenalan Diri', 'Education', NULL),
('Jurusan kuliah saya adalah...', 'My major is...', '제 전공은 ... 입니다', 'je jeongong-eun ... imnida', 'Phrase', 'Perkenalan Diri', 'Education', NULL),
('Perguruan Tinggi / Universitas', 'University / College', '대학교', 'daehakgyo', 'Noun', 'Perkenalan Diri', 'Place', NULL),
('Jurusan Kuliah / Bidang Studi', 'Major (Academic)', '전공', 'jeongong', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Lulus Kuliah / Sekolah', 'Graduate', '졸업하다', 'joreophada', 'Verb', 'Perkenalan Diri', 'V', '졸업하다'),
('Siswa / Murid Sekolah', 'Student', '학생', 'haksaeng', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Guru / Pengajar', 'Teacher', '선생님', 'seonsaengnim', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Dosen', 'Professor', '교수님', 'gyosunim', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Saya datang untuk belajar bahasa Korea', 'I came to learn Korean', '한국어를 배우러 왔습니다', 'hangugeoreul baeureo watseumnida', 'Phrase', 'Perkenalan Diri', 'Purpose', NULL),
('Saya datang untuk bekerja', 'I came to work', '취업을 위해 왔습니다', 'chwieobeul wihae watseumnida', 'Phrase', 'Perkenalan Diri', 'Purpose', NULL),
('Saya datang untuk berwisata', 'I came to travel', '여행하러 왔습니다', 'yeohaenghareo watseumnida', 'Phrase', 'Perkenalan Diri', 'Purpose', NULL),
('Target / Tujuan saya adalah...', 'My goal is...', '제 목표는 ... 입니다', 'je mokpyoneun ... imnida', 'Phrase', 'Perkenalan Diri', 'Purpose', NULL),
('Rencana / Maksud', 'Plan / Intention', '계획', 'gyehoek', 'Noun', 'Perkenalan Diri', 'S/O', NULL),
('Belajar / Menuntut Ilmu', 'Learn', '배우다', 'baeuda', 'Verb', 'Perkenalan Diri', 'V', '배우다');

-- ----------------------------------------------------------------
-- 2. KATEGORI: KATA GANTI & HUBUNGAN SOSIAL (대명사 & 사회관계)
-- Termasuk saya, kamu, kami, kita, bersama, sendiri, dll.
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Saya / Aku (Kasual/Akrab)', 'I / Me (Casual)', '나', 'na', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Saya (Sopan/Formal/Merendah)', 'I / Me (Polite/Humble)', '저', 'jeo', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Kamu / Kau (Kasual/Akrab)', 'You (Casual)', '너', 'neo', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Anda / Saudara (Sopan/Tertulis)', 'You (Polite/Formal)', '당신', 'dangsin', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Kalian (Akrab)', 'You all (Casual)', '너희', 'neohui', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Anda Sekalian / Hadirin', 'Everyone / Ladies & Gentlemen', '여러분', 'yeoreobun', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Kami / Kita (Biasa/Akrab)', 'We / Us (Standard)', '우리', 'uri', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Kami (Sopan/Merendahkan Diri)', 'We / Us (Humble Polite)', '저희', 'jeohui', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Dia (Laki-laki)', 'He / Him', '그', 'geu', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Dia (Perempuan)', 'She / Her', '그녀', 'geunyeo', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Mereka', 'They / Them', '그들', 'geudeul', 'Pronoun', 'Kata Ganti & Sosial', 'S', NULL),
('Bersama / Bareng (Formal)', 'Together (Formal)', '함께', 'hamkke', 'Adverb', 'Kata Ganti & Sosial', 'Adverb', NULL),
('Bersama / Bareng (Kasual/Percakapan)', 'Together (Conversational)', '같이', 'gachi', 'Adverb', 'Kata Ganti & Sosial', 'Adverb', NULL),
('Sendiri / Sendirian', 'Alone / By oneself', '혼자', 'honja', 'Adverb', 'Kata Ganti & Sosial', 'Adverb', NULL),
('Secara Mandiri / Diri Sendiri', 'By oneself / Autonomously', '스스로', 'seuseuro', 'Adverb', 'Kata Ganti & Sosial', 'Adverb', NULL),
('Teman', 'Friend', '친구', 'chingu', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Keluarga', 'Family', '가족', 'gajok', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Orang Tua', 'Parents', '부모님', 'bumonim', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Ayah', 'Father', '아버지', 'abeoji', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Ibu', 'Mother', '어머니', 'eomeoni', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Kakak Laki-laki (oleh Pria)', 'Older Brother (for male)', '형', 'hyeong', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Kakak Laki-laki (oleh Wanita)', 'Older Brother (for female)', '오빠', 'oppa', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Kakak Perempuan (oleh Pria)', 'Older Sister (for male)', '누나', 'nuna', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Kakak Perempuan (oleh Wanita)', 'Older Sister (for female)', '언니', 'eonni', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Adik', 'Younger Sibling', '동생', 'dongsaeng', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL),
('Orang / Manusia', 'Person / People', '사람', 'saram', 'Noun', 'Kata Ganti & Sosial', 'S/O', NULL);

-- ----------------------------------------------------------------
-- 3. KATEGORI: BELANJA & SUPERMARKET (쇼핑 & 마트)
-- Transaksi, harga, nota/struk, kantong plastik, kartu/tunai, diskon
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Supermarket / Mart', 'Supermarket / Mart', '마트', 'mateu', 'Noun', 'Belanja & Supermarket', 'Place', NULL),
('Minimarket 24 Jam', 'Convenience Store', '편의점', 'pyeon-uijeom', 'Noun', 'Belanja & Supermarket', 'Place', NULL),
('Pasar Tradisional', 'Traditional Market', '시장', 'sijang', 'Noun', 'Belanja & Supermarket', 'Place', NULL),
('Kasir / Meja Pembayaran', 'Cashier / Checkout Counter', '계산대', 'gyesandae', 'Noun', 'Belanja & Supermarket', 'Place', NULL),
('Berapa harganya?', 'How much is it?', '얼마예요?', 'eolmayeyo', 'Phrase', 'Belanja & Supermarket', 'Inquiry', NULL),
('Tolong berikan struk / nota', 'Please give me a receipt', '영수증 주세요', 'yeongsujeung juseyo', 'Phrase', 'Belanja & Supermarket', 'Request', NULL),
('Struk Belanja / Nota', 'Receipt', '영수증', 'yeongsujeung', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Kantong Belanja / Plastik', 'Shopping Bag / Plastic Bag', '봉투', 'bongtu', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Apakah Anda butuh kantong plastik?', 'Do you need a bag?', '봉투 필요하세요?', 'bongtu piryohaseyo', 'Phrase', 'Belanja & Supermarket', 'Question', NULL),
('Saya akan bayar dengan kartu', 'I will pay by card', '카드로 결제할게요', 'kadeuro gyeoljehalgeyo', 'Phrase', 'Belanja & Supermarket', 'Payment', NULL),
('Uang Tunai', 'Cash', '현금', 'hyeongeum', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Kartu Kredit / Debit', 'Credit Card', '신용카드', 'sin-yongkadeu', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Diskon / Potongan Harga', 'Discount / Sale', '할인', 'harin', 'Noun', 'Belanja & Supermarket', 'S/O', NULL),
('Tolong beri potongan harga ya', 'Please give a discount', '깎아 주세요', 'kkakka juseyo', 'Phrase', 'Belanja & Supermarket', 'Request', NULL),
('Pengembalian Dana / Refund', 'Refund', '환불', 'hwanbul', 'Noun', 'Belanja & Supermarket', 'S/O', NULL),
('Penukaran Barang', 'Exchange', '교환', 'gyohwan', 'Noun', 'Belanja & Supermarket', 'S/O', NULL),
('Keranjang Belanja', 'Shopping Basket', '바구니', 'baguni', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Troli Belanja Dorong', 'Shopping Cart', '카트', 'kateu', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Harga', 'Price', '가격', 'gagyeok', 'Noun', 'Belanja & Supermarket', 'S/O', NULL),
('Membeli', 'Buy', '사다', 'sada', 'Verb', 'Belanja & Supermarket', 'V', '사다'),
('Menjual', 'Sell', '팔다', 'palda', 'Verb', 'Belanja & Supermarket', 'V', '팔다'),
('Uang', 'Money', '돈', 'don', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Murah', 'Cheap', '싸다', 'ssada', 'Adjective', 'Belanja & Supermarket', 'A', '싸다'),
('Mahal', 'Expensive', '비싸다', 'bissada', 'Adjective', 'Belanja & Supermarket', 'A', '비싸다'),
('Baju / Pakaian', 'Clothes', '옷', 'ot', 'Noun', 'Belanja & Supermarket', 'O', NULL),
('Sepatu', 'Shoes', '신발', 'sinbal', 'Noun', 'Belanja & Supermarket', 'O', NULL);

-- ----------------------------------------------------------------
-- 4. KATEGORI: TIDUR & RUTINITAS HARIAN (수면 & 일상)
-- Rutinitas malam/pagi, selamat tidur, mimpi indah, mengantuk, lelah
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Tidur (Biasa)', 'Sleep (Standard)', '자다', 'jada', 'Verb', 'Tidur & Rutinitas', 'V', '자다'),
('Tidur (Sopan Tinggi / Honorifik)', 'Sleep (Honorific)', '주무시다', 'jumusida', 'Verb', 'Tidur & Rutinitas', 'V', '주무시다'),
('Selamat tidur (Sopan kepada yang dihormati)', 'Good night (Polite Honorific)', '안녕히 주무세요', 'annyeonghi jumuseyo', 'Phrase', 'Tidur & Rutinitas', 'Greeting', NULL),
('Selamat tidur (Akrab/Biasa)', 'Good night (Casual Polite)', '잘 자요', 'jal jayo', 'Phrase', 'Tidur & Rutinitas', 'Greeting', NULL),
('Semoga bermimpi indah ya', 'Sweet dreams', '좋은 꿈 꿔요', 'joeun kkum kwoyo', 'Phrase', 'Tidur & Rutinitas', 'Greeting', NULL),
('Mimpi', 'Dream', '꿈', 'kkum', 'Noun', 'Tidur & Rutinitas', 'O', NULL),
('Saya mengantuk sekali', 'I am very sleepy', '졸려요', 'jollyeoyo', 'Phrase', 'Tidur & Rutinitas', 'Feeling', NULL),
('Mengantuk', 'Feel sleepy / Drowsy', '졸리다', 'jollida', 'Verb', 'Tidur & Rutinitas', 'V', '졸리다'),
('Bangun Tidur', 'Wake up / Get up', '일어나다', 'ireonada', 'Verb', 'Tidur & Rutinitas', 'V', '일어나다'),
('Mencuci Muka', 'Wash face', '세수하다', 'sesuhada', 'Verb', 'Tidur & Rutinitas', 'V', '세수하다'),
('Mandi / Mandi Shower', 'Take a shower', '샤워하다', 'syawohada', 'Verb', 'Tidur & Rutinitas', 'V', '샤워하다'),
('Menyikat Gigi', 'Brush teeth', '양치하다', 'yangchihada', 'Verb', 'Tidur & Rutinitas', 'V', '양치하다'),
('Lelah / Capek', 'Tired / Exhausted', '피곤하다', 'pigonhada', 'Adjective', 'Tidur & Rutinitas', 'A', '피곤하다'),
('Beristirahat', 'Rest', '쉬다', 'swida', 'Verb', 'Tidur & Rutinitas', 'V', '쉬다'),
('Tempat Tidur / Kasur', 'Bed', '침대', 'chimdae', 'Noun', 'Tidur & Rutinitas', 'Place', NULL),
('Bantal', 'Pillow', '베개', 'begae', 'Noun', 'Tidur & Rutinitas', 'O', NULL),
('Selimut', 'Blanket', '이불', 'ibul', 'Noun', 'Tidur & Rutinitas', 'O', NULL),
('Pagi Hari', 'Morning', '아침', 'achim', 'Noun', 'Tidur & Rutinitas', 'Time', NULL),
('Siang Hari', 'Noon / Afternoon', '점심', 'jeomsim', 'Noun', 'Tidur & Rutinitas', 'Time', NULL),
('Malam Hari', 'Evening', '저녁', 'jeonyeok', 'Noun', 'Tidur & Rutinitas', 'Time', NULL),
('Larut Malam', 'Night', '밤', 'bam', 'Noun', 'Tidur & Rutinitas', 'Time', NULL);

-- ----------------------------------------------------------------
-- 5. KATEGORI: ARAH & JALANAN (길 찾기 & 길거리)
-- Menanyakan jalan, belok kanan/kiri, lurus terus, tersesat, jarak
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Permisi, saya tersesat di jalan', 'Excuse me, I am lost', '실례합니다, 길을 잃었어요', 'sillyehamnida, gireul ireosseoyo', 'Phrase', 'Arah & Jalan', 'Inquiry', NULL),
('Di mana toilet berada?', 'Where is the restroom?', '화장실이 어디에 있어요?', 'hwajangsil-i eodie isseoyo', 'Phrase', 'Arah & Jalan', 'Inquiry', NULL),
('Di mana lokasi...?', 'Where is...?', '... 어디에 있어요?', '... eodie isseoyo', 'Phrase', 'Arah & Jalan', 'Inquiry', NULL),
('Dari sini butuh waktu berapa lama?', 'How long does it take from here?', '여기서 얼마나 걸려요?', 'yeogiseo eolmana geollyeoyo', 'Phrase', 'Arah & Jalan', 'Inquiry', NULL),
('Jalan / Rute', 'Road / Street / Way', '길', 'gil', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Sebelah Kanan', 'Right / Right side', '오른쪽', 'oreunjjok', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Sebelah Kiri', 'Left / Left side', '왼쪽', 'oenjjok', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Lurus Terus', 'Straight ahead', '직진', 'jikjin', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Silakan belok ke kanan', 'Please turn right', '오른쪽으로 가세요', 'oreunjjogeuro gaseyo', 'Phrase', 'Arah & Jalan', 'Direction', NULL),
('Silakan belok ke kiri', 'Please turn left', '왼쪽으로 가세요', 'oenjjogeuro gaseyo', 'Phrase', 'Arah & Jalan', 'Direction', NULL),
('Silakan jalan lurus terus', 'Please go straight', '곧장 가세요', 'gotjang gaseyo', 'Phrase', 'Arah & Jalan', 'Direction', NULL),
('Seberang Jalan', 'Across the street', '건너편', 'geonneopyeon', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Dekat', 'Close / Near', '가깝다', 'gakkapda', 'Adjective', 'Arah & Jalan', 'A', '가깝다'),
('Jauh', 'Far', '멀다', 'meolda', 'Adjective', 'Arah & Jalan', 'A', '멀다'),
('Di Sini', 'Here', '여기', 'yeogi', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Di Sana', 'There', '거기', 'geogi', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Di Sana (Jauh dari keduanya)', 'Over there', '저기', 'jeogi', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Penyeberangan Pejalan Kaki (Zebra Cross)', 'Crosswalk', '횡단보도', 'hoengdanbodo', 'Noun', 'Arah & Jalan', 'Place', NULL),
('Lampu Pengatur Lalu Lintas', 'Traffic Light', '신호등', 'sinhodeung', 'Noun', 'Arah & Jalan', 'O', NULL),
('Toilet / Kamar Mandi', 'Restroom / Bathroom', '화장실', 'hwajangsil', 'Noun', 'Arah & Jalan', 'Place', NULL);

-- ----------------------------------------------------------------
-- 6. KATEGORI: RESTORAN & MAKANAN (식당 & 음식)
-- Memesan, rasa, peralatan makan, minta nota/air, ungkapan makan
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Buku Menu Makanan', 'Menu Book', '메뉴판', 'menyupan', 'Noun', 'Restoran & Makan', 'O', NULL),
('Permisi, kami mau pesan (Panggilan pelayan)', 'Excuse me, we would like to order', '여기요, 주문할게요', 'yeogiyo, jumunhalgeyo', 'Phrase', 'Restoran & Makan', 'Ordering', NULL),
('Tolong berikan yang ini ya', 'Please give me this', '이거 주세요', 'igeo juseyo', 'Phrase', 'Restoran & Makan', 'Ordering', NULL),
('Tolong minta air putih', 'Water, please', '물 좀 주세요', 'mul jom juseyo', 'Phrase', 'Restoran & Makan', 'Request', NULL),
('Tolong minta sendok dan sumpit', 'Please give spoon and chopsticks', '수저 주세요', 'sujeo juseyo', 'Phrase', 'Restoran & Makan', 'Request', NULL),
('Tolong hitung tagihannya / Minta bon', 'Bill, please', '계산해 주세요', 'gyesanhae juseyo', 'Phrase', 'Restoran & Makan', 'Payment', NULL),
('Selamat makan (Akan saya nikmati makanannya)', 'Bon appetit / I will eat well', '잘 먹겠습니다', 'jal meokgetseumnida', 'Phrase', 'Restoran & Makan', 'Courtesy', NULL),
('Terima kasih atas makanannya yang enak', 'Thank you for the delicious meal', '잘 먹었습니다', 'jal meogeotseumnida', 'Phrase', 'Restoran & Makan', 'Courtesy', NULL),
('Selamat menikmati makanannya', 'Enjoy your meal', '맛있게 드세요', 'masitge deuseyo', 'Phrase', 'Restoran & Makan', 'Courtesy', NULL),
('Enak / Lezat', 'Delicious', '맛있다', 'masitda', 'Adjective', 'Restoran & Makan', 'A', '맛있다'),
('Tidak Enak', 'Not delicious', '맛없다', 'madeopda', 'Adjective', 'Restoran & Makan', 'A', '맛없다'),
('Pedas', 'Spicy', '맵다', 'maepda', 'Adjective', 'Restoran & Makan', 'A', '맵다'),
('Manis', 'Sweet', '달다', 'dalda', 'Adjective', 'Restoran & Makan', 'A', '달다'),
('Asin', 'Salty', '짜다', 'jjada', 'Adjective', 'Restoran & Makan', 'A', '짜다'),
('Tawar / Kurang Bumbu', 'Bland', '싱겁다', 'singgeopda', 'Adjective', 'Restoran & Makan', 'A', '싱겁다'),
('Nasi / Makanan', 'Rice / Meal', '밥', 'bap', 'Noun', 'Restoran & Makan', 'O', NULL),
('Air', 'Water', '물', 'mul', 'Noun', 'Restoran & Makan', 'O', NULL),
('Roti', 'Bread', '빵', 'ppang', 'Noun', 'Restoran & Makan', 'O', NULL),
('Daging', 'Meat', '고기', 'gogi', 'Noun', 'Restoran & Makan', 'O', NULL),
('Kimchi', 'Kimchi', '김치', 'gimchi', 'Noun', 'Restoran & Makan', 'O', NULL),
('Kopi', 'Coffee', '커피', 'keopi', 'Noun', 'Restoran & Makan', 'O', NULL),
('Sendok', 'Spoon', '숟가락', 'sutgarak', 'Noun', 'Restoran & Makan', 'Instrument', NULL),
('Sumpit', 'Chopsticks', '젓가락', 'jeotgarak', 'Noun', 'Restoran & Makan', 'Instrument', NULL),
('Tisu / Serbet', 'Tissue / Napkin', '휴지', 'hyuji', 'Noun', 'Restoran & Makan', 'O', NULL),
('Bungkus untuk Dibawa Pulang (Take Out)', 'Take out / To go', '포장', 'pojang', 'Noun', 'Restoran & Makan', 'O', NULL),
('Makan', 'Eat', '먹다', 'meokda', 'Verb', 'Restoran & Makan', 'V', '먹다'),
('Minum', 'Drink', '마시다', 'masida', 'Verb', 'Restoran & Makan', 'V', '마시다'),
('Restoran / Rumah Makan', 'Restaurant', '식당', 'sikdang', 'Noun', 'Restoran & Makan', 'Place', NULL);

-- ----------------------------------------------------------------
-- 7. KATEGORI: TRANSPORTASI & PERJALANAN (교통 & 이동)
-- Subway, bus, taksi, halte, stasiun, transit, kartu T-Money
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Kereta Bawah Tanah / Subway', 'Subway', '지하철', 'jihacheol', 'Noun', 'Transportasi', 'Instrument', NULL),
('Stasiun Kereta / Subway', 'Subway / Train Station', '역', 'yeok', 'Noun', 'Transportasi', 'Place', NULL),
('Bus', 'Bus', '버스', 'beoseu', 'Noun', 'Transportasi', 'Instrument', NULL),
('Halte Bus', 'Bus Stop', '정류장', 'jeongnyujang', 'Noun', 'Transportasi', 'Place', NULL),
('Taksi', 'Taxi', '택시', 'taeksi', 'Noun', 'Transportasi', 'Instrument', NULL),
('Bandara Udara', 'Airport', '공항', 'gonghang', 'Noun', 'Transportasi', 'Place', NULL),
('Mobil', 'Car', '자동차', 'jadongcha', 'Noun', 'Transportasi', 'Instrument', NULL),
('Sepeda', 'Bicycle', '자전거', 'jajeon-geo', 'Noun', 'Transportasi', 'Instrument', NULL),
('Kartu Transportasi (T-Money)', 'Transit Card', '교통카드', 'gyotongkadeu', 'Noun', 'Transportasi', 'O', NULL),
('Tiket / Karcis', 'Ticket', '표', 'pyo', 'Noun', 'Transportasi', 'O', NULL),
('Naik (Kendaraan)', 'Ride / Get on', '타다', 'tada', 'Verb', 'Transportasi', 'V', '타다'),
('Turun (Dari Kendaraan)', 'Get off', '내리다', 'naerida', 'Verb', 'Transportasi', 'V', '내리다'),
('Transit / Pindah Kendaraan', 'Transfer lines', '갈아타다', 'garatada', 'Verb', 'Transportasi', 'V', '갈아타다'),
('Tolong antarkan saya ke...', 'Please take me to...', '... (으)로 가 주세요', '... euro ga juseyo', 'Phrase', 'Transportasi', 'Direction', NULL),
('Pemberhentian Berikutnya', 'Next stop', '다음 역', 'daeum yeok', 'Noun', 'Transportasi', 'Place', NULL),
('Pintu Keluar', 'Exit', '출구', 'chulgu', 'Noun', 'Transportasi', 'Place', NULL),
('Pergi', 'Go', '가다', 'gada', 'Verb', 'Transportasi', 'V', '가다'),
('Datang', 'Come', '오다', 'oda', 'Verb', 'Transportasi', 'V', '오다'),
('Cepat', 'Fast', '빠르다', 'ppareuda', 'Adjective', 'Transportasi', 'A', '빠르다'),
('Lambat', 'Slow', '느리다', 'neurida', 'Adjective', 'Transportasi', 'A', '느리다');

-- ----------------------------------------------------------------
-- 8. KATEGORI: KESEHATAN & DARURAT (병원 & 응급)
-- Rumah sakit, apotek, obat, sakit kepala, bantuan 119/112
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Tolong bantu saya!', 'Please help me!', '도와주세요!', 'dowajuseyo!', 'Phrase', 'Kesehatan & Darurat', 'Emergency', NULL),
('Rumah Sakit', 'Hospital', '병원', 'byeongwon', 'Noun', 'Kesehatan & Darurat', 'Place', NULL),
('Apotek', 'Pharmacy', '약국', 'yakguk', 'Noun', 'Kesehatan & Darurat', 'Place', NULL),
('Obat', 'Medicine', '약', 'yak', 'Noun', 'Kesehatan & Darurat', 'O', NULL),
('Saya merasa sakit', 'I am sick / hurting', '아파요', 'apayo', 'Phrase', 'Kesehatan & Darurat', 'Condition', NULL),
('Sakit / Nyeri', 'Sick / Hurt', '아프다', 'apeuda', 'Adjective', 'Kesehatan & Darurat', 'A', '아프다'),
('Sakit Kepala / Pusing', 'Headache', '두통', 'dutong', 'Noun', 'Kesehatan & Darurat', 'Condition', NULL),
('Masuk Angin / Flu', 'Cold / Flu', '감기', 'gamgi', 'Noun', 'Kesehatan & Darurat', 'Condition', NULL),
('Demam / Panas Badan', 'Fever', '열', 'yeol', 'Noun', 'Kesehatan & Darurat', 'Condition', NULL),
('Sakit Perut / Mulas', 'Stomachache', '배탈', 'baetal', 'Noun', 'Kesehatan & Darurat', 'Condition', NULL),
('Dokter', 'Doctor', '의사', 'uisa', 'Noun', 'Kesehatan & Darurat', 'S/O', NULL),
('Perawat', 'Nurse', '간호사', 'ganhosa', 'Noun', 'Kesehatan & Darurat', 'S/O', NULL),
('Panggilan Darurat Medis / Ambulans (119)', 'Emergency Ambulance (119)', '119 / 구급차', 'il-il-gu / gugeupcha', 'Noun', 'Kesehatan & Darurat', 'Emergency', NULL),
('Kantor Polisi / Polisi (112)', 'Police (112)', '경찰', 'gyeongchal', 'Noun', 'Kesehatan & Darurat', 'Emergency', NULL),
('Bahaya / Gawat!', 'Danger / Dangerous!', '위험해요!', 'wiheomhaeyo!', 'Phrase', 'Kesehatan & Darurat', 'Emergency', NULL);

-- ----------------------------------------------------------------
-- 9. KATEGORI: KANTOR & BELAJAR (직장 & 학교)
-- Bekerja, belajar, rapat, dokumen, jam kerja, rekan kantor
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Perusahaan / Kantor', 'Company / Office', '회사', 'hoesa', 'Noun', 'Kantor & Belajar', 'Place', NULL),
('Ruang Kantor', 'Office Room', '사무실', 'samusil', 'Noun', 'Kantor & Belajar', 'Place', NULL),
('Sekolah', 'School', '학교', 'hakgyo', 'Noun', 'Kantor & Belajar', 'Place', NULL),
('Perpustakaan', 'Library', '도서관', 'doseogwan', 'Noun', 'Kantor & Belajar', 'Place', NULL),
('Karyawan Kantor', 'Office Worker', '회사원', 'hoesawon', 'Noun', 'Kantor & Belajar', 'S/O', NULL),
('Berangkat Kerja', 'Go to work', '출근하다', 'chulgeunhada', 'Verb', 'Kantor & Belajar', 'V', '출근하다'),
('Pulang Kerja', 'Leave work', '퇴근하다', 'toegeunhada', 'Verb', 'Kantor & Belajar', 'V', '퇴근하다'),
('Rapat / Pertemuan Kerja', 'Meeting / Conference', '회의', 'hoeui', 'Noun', 'Kantor & Belajar', 'S/O', NULL),
('Dokumen / Berkas', 'Document / Paper', '서류', 'seoryu', 'Noun', 'Kantor & Belajar', 'O', NULL),
('Lembur Kerja', 'Overtime Work', '야근', 'yageun', 'Noun', 'Kantor & Belajar', 'S/O', NULL),
('Bekerja', 'Work', '일하다', 'ilhada', 'Verb', 'Kantor & Belajar', 'V', '일하다'),
('Belajar', 'Study', '공부하다', 'gongbuhada', 'Verb', 'Kantor & Belajar', 'V', '공부하다'),
('Membaca', 'Read', '읽다', 'ikda', 'Verb', 'Kantor & Belajar', 'V', '읽다'),
('Menulis', 'Write', '쓰다', 'sseuda', 'Verb', 'Kantor & Belajar', 'V', '쓰다'),
('Buku', 'Book', '책', 'chaek', 'Noun', 'Kantor & Belajar', 'O', NULL),
('Pena / Pulpen', 'Pen', '펜', 'pen', 'Noun', 'Kantor & Belajar', 'Instrument', NULL),
('Komputer', 'Computer', '컴퓨터', 'keompyuteo', 'Noun', 'Kantor & Belajar', 'O', NULL),
('Ponsel / HP', 'Cell Phone', '핸드폰', 'haendeupon', 'Noun', 'Kantor & Belajar', 'O', NULL),
('Rekan Kerja', 'Colleague', '동료', 'dongnyo', 'Noun', 'Kantor & Belajar', 'S/O', NULL),
('Ujian / Tes', 'Exam / Test', '시험', 'siheom', 'Noun', 'Kantor & Belajar', 'S/O', NULL),
('Sibuk', 'Busy', '바쁘다', 'bappeuda', 'Adjective', 'Kantor & Belajar', 'A', '바쁘다');

-- ----------------------------------------------------------------
-- 10. KATEGORI: EMOSI, CUACA & WAKTU (감정, 날씨 & 시간)
-- Perasaan, kondisi cuaca, waktu sekarang/besok
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Senang / Gembira', 'Happy / Glad', '기쁘다', 'gippeuda', 'Adjective', 'Emosi & Cuaca', 'A', '기쁘다'),
('Sedih', 'Sad', '슬프다', 'seulpeuda', 'Adjective', 'Emosi & Cuaca', 'A', '슬프다'),
('Lapar', 'Hungry', '배고프다', 'baegopeuda', 'Adjective', 'Emosi & Cuaca', 'A', '배고프다'),
('Kenyang', 'Full (Stomach)', '배부르다', 'baebureuda', 'Adjective', 'Emosi & Cuaca', 'A', '배부르다'),
('Bagus / Baik', 'Good / Fine', '좋다', 'jota', 'Adjective', 'Emosi & Cuaca', 'A', '좋다'),
('Buruk / Jelek', 'Bad', '나쁘다', 'nappeuda', 'Adjective', 'Emosi & Cuaca', 'A', '나쁘다'),
('Cuaca', 'Weather', '날씨', 'nalssi', 'Noun', 'Emosi & Cuaca', 'S', NULL),
('Cerah (Cuaca)', 'Clear / Sunny', '맑다', 'makda', 'Adjective', 'Emosi & Cuaca', 'A', '맑다'),
('Hujan Turun', 'Rain', '비가 오다', 'biga oda', 'Verb', 'Emosi & Cuaca', 'V', '오다'),
('Salju Turun', 'Snow', '눈이 오다', 'nuni oda', 'Verb', 'Emosi & Cuaca', 'V', '오다'),
('Panas (Cuaca)', 'Hot', '덥다', 'deopda', 'Adjective', 'Emosi & Cuaca', 'A', '덥다'),
('Dingin (Cuaca)', 'Cold', '춥다', 'chupda', 'Adjective', 'Emosi & Cuaca', 'A', '춥다'),
('Hari ini', 'Today', '오늘', 'oneul', 'Noun', 'Emosi & Cuaca', 'Time', NULL),
('Besok', 'Tomorrow', '내일', 'naeil', 'Noun', 'Emosi & Cuaca', 'Time', NULL),
('Sekarang', 'Now', '지금', 'jigeum', 'Noun', 'Emosi & Cuaca', 'Time', NULL);

-- ----------------------------------------------------------------
-- 11. KATEGORI: PERCAKAPAN & UNGKAPAN UMUM (인사 & 기본 표현)
-- Salam, terima kasih, maaf, ya, tidak
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Halo / Apa kabar?', 'Hello / How are you?', '안녕하세요', 'annyeonghaseyo', 'Phrase', 'Percakapan Umum', 'Greeting', NULL),
('Terima kasih banyak (Formal)', 'Thank you very much (Formal)', '감사합니다', 'gamsahamnida', 'Phrase', 'Percakapan Umum', 'Courtesy', NULL),
('Terima kasih (Informal Sopan)', 'Thank you (Informal Polite)', '고마워요', 'gomawoyo', 'Phrase', 'Percakapan Umum', 'Courtesy', NULL),
('Sama-sama / Kembali', 'You are welcome', '천만에요', 'cheonman-eyo', 'Phrase', 'Percakapan Umum', 'Courtesy', NULL),
('Mohon maaf (Sopan)', 'I am sorry (Polite)', '죄송합니다', 'joesonghamnida', 'Phrase', 'Percakapan Umum', 'Courtesy', NULL),
('Selamat tinggal (Kepada yang pergi)', 'Goodbye (To someone leaving)', '안녕히 가세요', 'annyeonghi gaseyo', 'Phrase', 'Percakapan Umum', 'Greeting', NULL),
('Selamat tinggal (Kepada yang tinggal)', 'Goodbye (To someone staying)', '안녕히 계세요', 'annyeonghi gyeseyo', 'Phrase', 'Percakapan Umum', 'Greeting', NULL),
('Senang bertemu denganmu', 'Nice to meet you', '만나서 반갑습니다', 'mannaseo bangapseumnida', 'Phrase', 'Percakapan Umum', 'Greeting', NULL),
('Ya / Benar', 'Yes / That is right', '네', 'ne', 'Phrase', 'Percakapan Umum', 'Response', NULL),
('Tidak / Bukan', 'No / It is not', '아니요', 'aniyo', 'Phrase', 'Percakapan Umum', 'Response', NULL);

-- ----------------------------------------------------------------
-- 12. KATEGORI: PARTIKEL TATA BAHASA (조사 - PARTICLES)
-- ----------------------------------------------------------------
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, category, sentence_pattern, base_verb) VALUES
('Partikel Topik (Ada Batchim)', 'Topic Particle (Consonant)', '은', 'eun', 'Particle', 'Tata Bahasa & Partikel', 'Topic-C', NULL),
('Partikel Topik (Tanpa Batchim / Vokal)', 'Topic Particle (Vowel)', '는', 'neun', 'Particle', 'Tata Bahasa & Partikel', 'Topic-V', NULL),
('Partikel Subjek (Ada Batchim)', 'Subject Particle (Consonant)', '이', 'i', 'Particle', 'Tata Bahasa & Partikel', 'Subj-C', NULL),
('Partikel Subjek (Tanpa Batchim / Vokal)', 'Subject Particle (Vowel)', '가', 'ga', 'Particle', 'Tata Bahasa & Partikel', 'Subj-V', NULL),
('Partikel Objek (Ada Batchim)', 'Object Particle (Consonant)', '을', 'eul', 'Particle', 'Tata Bahasa & Partikel', 'Obj-C', NULL),
('Partikel Objek (Tanpa Batchim / Vokal)', 'Object Particle (Vowel)', '를', 'reul', 'Particle', 'Tata Bahasa & Partikel', 'Obj-V', NULL),
('Partikel Lokasi Aksi Aktif (Di)', 'Action Location (At/In)', '에서', 'eseo', 'Particle', 'Tata Bahasa & Partikel', 'Loc-Action', NULL),
('Partikel Waktu / Keberadaan / Tujuan (Ke/Di/Pada)', 'Location / Time / To', '에', 'e', 'Particle', 'Tata Bahasa & Partikel', 'Loc-Static/Time', NULL),
('Partikel Sarana / Arah (Dengan / Lewat / Ke)', 'Instrument / Direction', '으로 / 로', 'euro / ro', 'Particle', 'Tata Bahasa & Partikel', 'Instrument', NULL);

-- ================================================================
-- SEED DATA: EXAM PACKAGES (LEVEL 1 s.d. 4)
-- ================================================================
INSERT INTO exam_packages (id, title, level, total_questions) VALUES
(1, 'Level 1: Hangeul, Percakapan & Tren TOPIK I Terkini', 1, 15),
(2, 'Level 2: Struktur Kalimat SOV & Arah Lokasi', 2, 5),
(3, 'Level 3: Konjugasi Sopan & Kehidupan Sehari-hari', 3, 5),
(4, 'Level 4: TOPIK I Mastery & Tata Bahasa Lanjutan', 4, 5);

-- ================================================================
-- SEED DATA: EXAM QUESTIONS
-- ================================================================

-- ----------------------------------------------------------------
-- LEVEL 1: HANGEUL, PERCAKAPAN & TREN TOPIK I TERKINI (15 SOAL LENGKAP)
-- Tren 2 Tahun Terakhir: Perkenalan, Mart, Restoran, Arah, Waktu, Partikel
-- ----------------------------------------------------------------

-- Soal 1: Perkenalan Diri (Asal Negara)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'dialog_origin', 'Perhatikan percakapan perkenalan diri berikut: 가: "어디에서 왔어요?" (Dari mana Anda berasal?) / 나: "___."', '어디에서 왔어요? 저는 인도네시아에서 왔어요.', '저는 인도네시아에서 왔어요', '저는 도서관에 가요', '사과를 좋아해요', '오늘 날씨가 추워요', 'A', 'Pertanyaan "어디에서 왔어요?" menanyakan asal negara/daerah. Jawaban yang tepat menyatakan tempat asal dengan partikel 에서 (dari) dan 왔어요 (datang): "저는 인도네시아에서 왔어요" (Saya berasal dari Indonesia).', '"어디에서 왔어요?"는 출신 국가나 고향을 묻는 질문입니다. 출신지를 나타내는 조사 ''에서''와 과거형 ''왔어요''를 결합한 "저는 인도네시아에서 왔어요"(인도네시아 출신입니다)가 가장 자연스럽고 올바른 대답입니다.');

-- Soal 2: Belanja di Supermarket (Menanyakan Harga)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'shopping_price', 'Di supermarket, Anda ingin menanyakan harga sebuah apel. Kalimat tanya apa yang paling lazim digunakan?', '사과는 얼마예요?', '사과가 어디에 있어요?', '사과는 얼마예요?', '사과를 먹었어요?', '사과가 맛있어요?', 'B', 'Pola baku untuk menanyakan harga barang dalam bahasa Korea adalah "얼마예요?" (Berapa harganya?). Untuk menanyakan harga apel, gunakan "사과는 얼마예요?".', '물건의 가격을 물어볼 때는 "얼마예요?"라는 표현을 씁니다. 사과의 가격을 묻는 가장 정확한 표현은 "사과는 얼마예요?"(How much is the apple?)입니다.');

-- Soal 3: Partikel Topik (은/는)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'particle_topic', 'Pilihlah partikel topik yang tepat untuk kata: "선생님" (Guru) pada kalimat: "선생님___ 한국어를 가르치십니다."', '선생님은 한국어를 가르치십니다.', '은', '는', '이', '를', 'A', 'Kata "선생님" berakhiran konsonan akhir/batchim (ㅁ pada suku kata 님). Sesuai hukum fonologi Korea, kata yang memiliki batchim wajib menggunakan partikel topik "은" (bukan 는).', '''선생님''의 마지막 음절인 ''님''에 받침(ㅁ)이 있으므로, 받침 있는 명사 뒤에 결합하는 주제격 조사 ''은''을 써야 합니다. (선생님은)');

-- Soal 4: Partikel Objek (을/를)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'particle_object', 'Lengkapilah kalimat berikut dengan partikel objek yang benar: "저는 아침에 빵___ 먹어요." (Saya sarapan makan roti).', '저는 아침에 빵을 먹어요.', '을', '를', '은', '가', 'A', 'Kata benda objek "빵" (roti) berakhiran konsonan akhir/batchim (ㅇ), sehingga menggunakan partikel objek "을". Kata berakhiran vokal barulah menggunakan "를".', '목적어인 ''빵''은 받침(ㅇ)이 있는 음절이므로 목적격 조사 ''을''이 결합하여 ''빵을''이 됩니다. 받침이 없는 단어(예: 사과)에는 ''를''을 붙입니다.');

-- Soal 5: Arah & Navigasi di Jalan
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'dialog_direction', 'Lengkapilah dialog petunjuk arah: 가: "실례합니다, 지하철역이 어디에 있어요?" / 나: "저 건너편에 있어요. 오른쪽으로 ___."', '실례합니다, 지하철역이 어디에 있어요? 저 건너편에 있어요. 오른쪽으로 가세요.', '자요', '가세요', '먹어요', '읽어요', 'B', 'Konteks percakapan di jalan menanyakan letak stasiun subway. Jawaban mengarahkan orang untuk berjalan ke arah kanan ("오른쪽으로 가세요" = Silakan belok/jalan ke kanan).', '길을 묻고 안내하는 상황입니다. 방향 조사 ''(으)로''와 이동 명령 표현인 ''가세요''가 결합하여 "오른쪽으로 가세요"(Please go to the right)가 문맥상 정답입니다.');

-- Soal 6: Partikel Lokasi Aksi Aktif (에서)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'particle_action_location', 'Untuk menyatakan tempat terjadinya suatu aksi aktif ("Saya belajar bahasa Korea di perpustakaan"), partikel apa yang tepat pada: "저는 도서관___ 한국어를 공부해요."?', '저는 도서관에서 한국어를 공부해요.', '에', '에서', '으로', '를', 'B', 'Partikel "에서" digunakan untuk menandai tempat di mana suatu kegiatan aktif sedang berlangsung (공부하다 = belajar). Partikel "에" hanya dipakai untuk tempat keberadaan statis (ada/tidak ada) atau tujuan perpindahan.', '행동이나 동작(공부하다)이 구체적으로 일어나는 장소를 나타낼 때는 장소격 조사 ''에서''를 사용합니다. ''에''는 정적 위치나 시간, 목적지에 쓰입니다.');

-- Soal 7: Memesan Makanan di Restoran
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'restaurant_ordering', 'Di restoran, ketika Anda ingin memesan 1 porsi bibimbap dengan sopan kepada pelayan, ungkapan apa yang tepat?', '비빔밥 하나 주세요.', '비빔밥 하나 주세요', '비빔밥이 비싸요', '비빔밥을 안 먹어요', '식당이 어디예요', 'A', 'Pola baku yang sopan saat memesan makanan di Korea adalah menyebutkan nama hidangan + satuan/jumlah + "주세요" (Tolong berikan): "비빔밥 하나 주세요" (Tolong 1 porsi bibimbap).', '식당에서 음식을 정중하게 주문할 때는 ''음식 이름 + 수량 + 주세요'' 구조를 사용합니다. 따라서 "비빔밥 하나 주세요"(비빔밥 1인분 부탁합니다)가 정답입니다.');

-- Soal 8: Waktu Tidur & Kesopanan Malam Hari
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'courtesy_sleep', 'Sebelum beristirahat tidur malam, ucapan selamat tidur ragam sopan/honorifik kepada orang yang lebih tua adalah...', '안녕히 주무세요.', '안녕히 가세요', '안녕히 계세요', '안녕히 주무세요', '축하합니다', 'C', 'Salam selamat tidur sopan/honorifik kepada orang tua atau yang dihormati adalah "안녕히 주무세요". Sedangkan "잘 자요" digunakan untuk teman sebaya atau yang lebih muda.', '밤에 잠자리에 들기 전 어른께 올리는 높임말 밤 인사는 "안녕히 주무세요"(Good night)입니다. 친구나 아랫사람에게는 "잘 자" 또는 "잘 자요"를 씁니다.');

-- Soal 9: Partikel Sarana / Transportasi (으로/로)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'instrument_transport', 'Isilah partikel sarana yang tepat: "저는 회사에 지하철___ 가요." (Saya pergi ke kantor naik subway).', '저는 회사에 지하철로 가요.', '로', '으로', '에서', '에', 'A', 'Hukum fonologi partikel sarana "(으)로": Kata yang berakhiran huruf vokal ATAU konsonan akhir "ㄹ" (seperti 지하철 yang berakhiran batchim ㄹ) menggunakan "로" (bukan 으로).', '수단이나 방법을 나타내는 조사 ''(으)로''는 받침이 없거나 ''ㄹ'' 받침으로 끝나는 명사 뒤에 ''로''가 결합합니다. ''지하철''은 ''ㄹ'' 받침이므로 ''지하철로''가 정확한 표현입니다.');

-- Soal 10: Rutinitas Jam Bangun Pagi
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'time_particle_schedule', '가: "아침 몇 시에 일어나요?" / 나: "저는 7시___ 일어나요." Titik-titik diisi dengan partikel waktu...', '아침 몇 시에 일어나요? 저는 7시에 일어나요.', '에', '에서', '은', '로', 'A', 'Penanda waktu spesifik (seperti jam 7 = 7시, hari, tanggal) wajib dilekatkan partikel waktu "에" ("7시에 일어나요" = Bangun pada jam 7).', '구체적인 시각이나 날짜, 요일 등 시간 명사 뒤에는 시간을 나타내는 격조사 ''에''가 붙습니다. "7시에 일어나요"(I wake up at 7 o''clock)가 올바릅니다.');

-- Soal 11: Tujuan Kedatangan (Maksud Perpindahan)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'grammar_purpose', 'Pertanyaan: "한국에 왜 왔어요?" (Mengapa Anda datang ke Korea?). Pilihlah jawaban yang menyatakan tujuan untuk belajar:', '한국에 왜 왔어요? 한국어를 배우러 왔어요.', '한국어를 배우러 왔어요', '밥을 먹었어요', '집에 가고 싶어요', '날씨가 좋아요', 'A', 'Tata bahasa akhiran "-(으)러 오다/가다" digunakan untuk menyatakan tujuan perpindahan (datang/pergi untuk suatu maksud). "한국어를 배우러 왔어요" artinya datang untuk belajar bahasa Korea.', '이동의 목적을 밝힐 때는 동사 어간에 목적 연결 어미 ''-(으)러 가다/오다''를 사용합니다. 한국어를 배우려는 목적을 명확히 표현한 "한국어를 배우러 왔어요"가 정답입니다.');

-- Soal 12: Membayar di Kasir (Kartu Pembayaran)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'transaction_card', 'Di kasir minimarket atau supermarket, kalimat apa yang lazim Anda sampaikan ketika hendak membayar dengan kartu bank?', '카드로 결제할게요.', '카드로 결제할게요', '현금이 없어요', '봉투를 버리세요', '영수증을 찢으세요', 'A', '"카드로 결제할게요" artinya "Saya akan bayar menggunakan kartu". Ini adalah ungkapan standar dan sangat umum dalam transaksi harian di Korea.', '상점이나 편의점에서 신용카드로 결제하겠다는 의사를 밝히는 가장 표준적인 표현은 "카드로 결제할게요"(I will pay by card)입니다.');

-- Soal 13: Konjugasi Bentuk Sekarang Sopan (-아요/어요)
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'conjugation_present', 'Ubahlah kata dasar kerja "보다" (melihat/menonton) ke dalam bentuk informal sopan sekarang (-아요/어요):', '텔레비전을 봐요.', '보아요', '봐요', '보해요', '보었어요', 'B', 'Akar kata "보" memiliki vokal dasar "ㅗ". Saat bertemu akhiran "-아요", terjadi kontraksi vokal (ㅗ + ㅏ melebur menjadi ㅘ) sehingga bentuk bakunya adalah "봐요".', '동사 ''보다''의 어간 ''보-''는 양성모음(ㅗ)을 가지므로 ''-아요''와 결합합니다. 이때 ''보 + 아요''가 축약되어 ''봐요''(I watch/see) 형태로 활용됩니다.');

-- Soal 14: Keadaan Darurat & Beli Obat
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'emergency_pharmacy', 'Anda tiba-tiba merasa sakit kepala (두통) dan demam (열). Ke manakah tempat yang tepat untuk membeli obat (약)?', '머리가 아파요. 약국에 가요.', '은행', '약국', '우체국', '서점', 'B', '"약국" artinya apotek (tempat membeli obat / 약). Pilihan lain: 은행 (bank), 우체국 (kantor pos), 서점 (toko buku).', '두통이나 감기 등으로 약(Medicine)을 구매할 수 있는 장소는 ''약국''(Pharmacy)입니다. (은행: Bank, 우체국: Post Office, 서점: Bookstore)');

-- Soal 15: Status Pendidikan / Mahasiswa
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'identity_student', 'Lengkapilah dialog: 가: "직업이 뭐예요?" (Apa pekerjaan Anda?) / 나: "저는 대학교에서 공부하는 ___입니다."', '직업이 뭐예요? 저는 대학교에서 공부하는 대학생입니다.', '의사', '회사원', '대학생', '요리사', 'C', 'Orang yang menempuh pendidikan di universitas/perguruan tinggi (대학교) disebut "대학생" (Mahasiswa). 의사 = Dokter, 회사원 = Karyawan kantor, 요리사 = Koki.', '대학교에서 학문을 공부하는 신분은 ''대학생''(University student)입니다. 문장의 단서인 ''대학교에서 공부하는...''에 부합하는 명사는 ''대학생''입니다.');

-- ----------------------------------------------------------------
-- LEVEL 2: STRUKTUR KALIMAT SOV & ARAH LOKASI
-- ----------------------------------------------------------------
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(2, 'sov_structure', 'Bagaimana susunan SOV bahasa Korea untuk kalimat: "Budi membaca buku"?', '부디는 책을 읽어요.', '부디는 읽어요 책을', '부디는 책을 읽어요', '책을 부디는 읽어요', '읽어요 부디는 책을', 'B', 'Struktur baku bahasa Korea adalah Subjek (부디는) + Objek (책을) + Predikat (읽어요).', '한국어의 기본 어순은 주어(부디는) + 목적어(책을) + 서술어(읽어요)인 SOV 구조를 따릅니다.'),
(2, 'particle_direction', 'Lengkapilah kalimat menuju tujuan: "저는 내일 학교___ 가요" (Saya besok pergi ke sekolah).', '저는 내일 학교에 가요.', '에', '에서', '을', '으로', 'A', 'Kata kerja perpindahan/arah seperti 가다 (pergi) dan 오다 (datang) berpasangan dengan partikel tujuan "에".', '가다, 오다와 같은 방향 이동 동사는 목적지 조사 ''에''와 호응합니다. (학교에 가요)'),
(2, 'instrument_rieul', 'Pilihlah partikel sarana/alat yang benar: "지하철___ 가요" (Pergi dengan subway).', '지하철로 가요.', '으로', '로', '에서', '에', 'B', 'Perhatian! Kata "지하철" berakhiran batchim "ㄹ". Sesuai aturan fonologi Korea, kata berakhiran vokal ATAU batchim "ㄹ" menggunakan "로" (bukan 으로).', '''지하철''은 ''ㄹ'' 받침으로 끝나므로 조사 ''(으)로'' 중 ''로''를 붙여 ''지하철로''가 됩니다.'),
(2, 'sov_translation', 'Terjemahkan secara tepat: "Saya minum air di rumah."', '저는 집에서 물을 마셔요.', '저는 마셔요 집에서 물을', '저는 집에서 물을 마셔요', '저는 물을 집에서 마셔요', '집에서 저는 마셔요 물을', 'B', 'Pola kalimat bahasa Korea yang paling alami adalah Subjek (저는) + Keterangan Tempat (집에서) + Objek (물을) + Predikat (마셔요).', '자연스러운 한국어 문장 구성은 주어(저는) + 장소(집에서) + 목적어(물을) + 동사(마셔요) 순서입니다.'),
(2, 'particle_instrument', 'Gunakan partikel sarana yang tepat: "연필___ 글씨를 써요" (Menulis huruf dengan pensil).', '연필로 글씨를 써요.', '으로', '로', '에', '을', 'B', 'Kata "연필" berakhiran batchim "ㄹ", sehingga menggunakan partikel sarana "로".', '''연필''은 ''ㄹ'' 받침을 가지므로 도구 조사 ''로''가 결합하여 ''연필로''(With a pencil)가 됩니다.');

-- ----------------------------------------------------------------
-- LEVEL 3: KONJUGASI SOPAN & KEHIDUPAN SEHARI-HARI
-- ----------------------------------------------------------------
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(3, 'conjugation_informal', 'Bagaimana konjugasi bentuk informal sopan (-아요/어요) dari kata kerja "먹다" (makan)?', '먹어요', '먹아요', '먹어요', '먹해요', '먹습니다', 'B', 'Vokal dasar kata kerja "먹다" adalah "ㅓ" (bukan ㅏ/ㅗ), sehingga dilekatkan akhiran "-어요" menjadi "먹어요".', '동사 ''먹다''의 어간 모음은 음성모음(ㅓ)이므로 ''-어요''가 결합하여 ''먹어요''가 됩니다.'),
(3, 'conjugation_hada', 'Bentuk informal sopan dari kata kerja "공부하다" (belajar) adalah...', '공부해요', '공부하요', '공부해요', '공부했어요', '공부합니다', 'B', 'Semua kata kerja berakhiran "하다" berubah menjadi "해요" dalam bentuk informal sopan sekarang.', '''하다''로 끝나는 모든 동사와 형용사는 현재 비격식 존댓말에서 ''해요''로 바뀝니다. (공부해요)'),
(3, 'conjugation_formal', 'Ubahlah kata kerja "가다" (pergi) ke dalam bentuk formal sopan (-ㅂ니다/습니다):', '갑니다', '가습니다', '갑니다', '가요', '갔습니다', 'B', 'Akar kata "가" tidak memiliki batchim (berakhiran vokal), maka langsung digabung dengan "-ㅂ니다" menjadi "갑니다".', '어간 ''가-''에 받침이 없으므로 격식체 종결어미 ''-ㅂ니다''가 직접 붙어 ''갑니다''가 됩니다.'),
(3, 'conjugation_past', 'Manakah bentuk lampau (-았/었어요) yang benar dari "보다" (melihat)?', '봤어요', '보았어요 / 봤어요', '보었어요', '보해요', '봅니다', 'A', 'Vokal akar kata "ㅗ" berkontraksi dengan "ㅏ" membentuk "ㅘ" lampau: 보 + 았어요 = 봤어요.', '어간 ''보-''에 과거 시제 선어말어미 ''-았-''이 결합하면 ''보았-''이 축약되어 ''봤어요''가 됩니다.'),
(3, 'honorific_polite', 'Pilihlah bentuk formal sopan dari kata sifat "좋다" (bagus):', '좋습니다', '좋습니다', '좋ㅂ니다', '좋아요', '좋았습니다', 'A', 'Akar kata "좋" memiliki batchim (ㅎ), sehingga dilekatkan akhiran "-습니다" menjadi "좋습니다".', '형용사 어간 ''좋-''에 받침(ㅎ)이 있으므로 격식체 종결어미 ''-습니다''가 결합하여 ''좋습니다''가 됩니다.');

-- ----------------------------------------------------------------
-- LEVEL 4: TOPIK I MASTERY & TATA BAHASA LANJUTAN
-- ----------------------------------------------------------------
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(4, 'reading_comprehension', 'Bacalah percakapan: 가: "어디에 가요?" / 나: "도서관에 가요. 책을 ___."', '도서관에 가요. 책을 읽어요.', '마셔요', '읽어요', '자요', '만나요', 'B', 'Konteks pergi ke perpustakaan (도서관) berpasangan logis dengan membaca buku (책을 읽어요).', '도서관(장소)에 가서 하는 행위로 가장 자연스러운 것은 책을 읽는 것(읽어요)입니다.'),
(4, 'irregular_rieul', 'Konjugasikan kata kerja tidak beraturan "만들다" (membuat) ke dalam bentuk formal (-ㅂ니다/습니다):', '만듭니다', '만들습니다', '만듭니다', '만들ㅂ니다', '만들어요', 'B', 'Aturan tidak beraturan "ㄹ": saat bertemu dengan akhiran berawalan ㄴ, ㅂ, ㅅ, konsonan "ㄹ" gugur sehingga 만들다 menjadi "만듭니다".', '''ㄹ'' 불규칙 활용: 어간 끝소리 ''ㄹ''이 ''ㄴ, ㅂ, ㅅ'' 앞에서 탈락하여 ''만들다''가 ''만듭니다''가 됩니다.'),
(4, 'future_intention', 'Pilihlah bentuk rencana/masa depan (-(으)ㄹ 거예요) untuk "먹다":', '먹을 거예요', '먹ㄹ 거예요', '먹을 거예요', '먹겠어요', '먹는 거예요', 'B', 'Akar kata "먹" berakhiran batchim (ㄱ), sehingga menggunakan "-을 거예요" menjadi "먹을 거예요".', '어간 ''먹-''에 받침이 있으므로 미래/의지 표현인 ''-을 거예요''를 사용하여 ''먹을 거예요''가 됩니다.'),
(4, 'particle_contrast', 'Lengkapi dengan partikel pembanding yang tepat: "사과는 맛있어요. 하지만 바나나___ 맛없어요."', '사과는 맛있어요. 하지만 바나나는 맛없어요.', '가', '는', '를', '도', 'B', 'Partikel topik "는/은" sering digunakan untuk memberikan fungsi kontras/pembanding antara dua hal (apel vs pisang).', '주제격 조사 ''은/는''은 두 대상을 대조하거나 비교할 때 사용됩니다. (사과는 맛있어요. 하지만 바나나는 맛없어요.)'),
(4, 'time_particle', 'Pilihlah partikel penanda waktu yang benar: "저는 아침 8시___ 일어나요" (Saya bangun pada jam 8 pagi).', '저는 아침 8시에 일어나요.', '에', '에서', '을', '로', 'A', 'Waktu spesifik (jam, tanggal, hari) ditandai dengan partikel "에".', '특정 시각(8시)을 나타낼 때는 시간의 부사격 조사 ''에''를 붙여 "8시에 일어나요"가 됩니다.');

