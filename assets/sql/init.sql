-- ================================================================
-- TRILINGUAL KOREAN OFFLINE MASTER - SQL INITIALIZATION SCHEMA
-- ================================================================

-- 1. Table: dictionary
CREATE TABLE IF NOT EXISTS dictionary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    indonesian TEXT NOT NULL,
    english TEXT NOT NULL,
    korean_hangul TEXT NOT NULL,
    korean_roman TEXT NOT NULL,
    pos TEXT NOT NULL,
    sentence_pattern TEXT,
    base_verb TEXT
);

CREATE INDEX IF NOT EXISTS idx_dict_indonesian ON dictionary(indonesian);
CREATE INDEX IF NOT EXISTS idx_dict_english ON dictionary(english);
CREATE INDEX IF NOT EXISTS idx_dict_korean_hangul ON dictionary(korean_hangul);
CREATE INDEX IF NOT EXISTS idx_dict_pos ON dictionary(pos);

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
-- SEED DATA: DICTIONARY ENTRIES (PRONOUNS, NOUNS, VERBS, ADJECTIVES, PHRASES)
-- ================================================================

-- Pronouns & Common Subjects
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, sentence_pattern, base_verb) VALUES
('Saya / Aku (Informal)', 'I / Me (Informal)', '나', 'na', 'Pronoun', 'S', NULL),
('Saya / Saya (Sopan/Formal)', 'I / Me (Polite)', '저', 'jeo', 'Pronoun', 'S', NULL),
('Kamu / Kau', 'You (Informal)', '너', 'neo', 'Pronoun', 'S', NULL),
('Anda / Saudara', 'You (Polite)', '당신', 'dangsin', 'Pronoun', 'S', NULL),
('Kami / Kita', 'We / Us', '우리', 'uri', 'Pronoun', 'S', NULL),
('Mereka', 'They / Them', '그들', 'geudeul', 'Pronoun', 'S', NULL),
('Budi (Nama Orang)', 'Budi (Person)', '부디', 'budi', 'Noun', 'S', NULL),
('Minho (Nama Orang)', 'Minho (Person)', '민호', 'minho', 'Noun', 'S', NULL),
('Siswa / Murid', 'Student', '학생', 'haksaeng', 'Noun', 'S/O', NULL),
('Guru', 'Teacher', '선생님', 'seonsaengnim', 'Noun', 'S/O', NULL),
('Teman', 'Friend', '친구', 'chingu', 'Noun', 'S/O', NULL),
('Ibu', 'Mother', '어머니', 'eomeoni', 'Noun', 'S/O', NULL),
('Ayah', 'Father', '아버지', 'abeoji', 'Noun', 'S/O', NULL),
('Adik', 'Younger Sibling', '동생', 'dongsaeng', 'Noun', 'S/O', NULL),
('Dokter', 'Doctor', '의사', 'uisa', 'Noun', 'S/O', NULL),
('Pegawai Kantor', 'Office Worker', '회사원', 'hoesawon', 'Noun', 'S/O', NULL);

-- Places (Locations)
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, sentence_pattern, base_verb) VALUES
('Rumah', 'Home / House', '집', 'jip', 'Noun', 'Place', NULL),
('Sekolah', 'School', '학교', 'hakgyo', 'Noun', 'Place', NULL),
('Perpustakaan', 'Library', '도서관', 'doseogwan', 'Noun', 'Place', NULL),
('Restoran / Rumah Makan', 'Restaurant', '식당', 'sikdang', 'Noun', 'Place', NULL),
('Kantor', 'Office', '사무실', 'samusil', 'Noun', 'Place', NULL),
('Pasar', 'Market', '시장', 'sijang', 'Noun', 'Place', NULL),
('Taman', 'Park', '공원', 'gongwon', 'Noun', 'Place', NULL),
('Rumah Sakit', 'Hospital', '병원', 'byeongwon', 'Noun', 'Place', NULL),
('Toko Buku', 'Bookstore', '서점', 'seojeom', 'Noun', 'Place', NULL),
('Korea', 'Korea', '한국', 'hanguk', 'Noun', 'Place', NULL),
('Indonesia', 'Indonesia', '인도네시아', 'indonesia', 'Noun', 'Place', NULL),
('Kafe / Kedai Kopi', 'Cafe', '카페', 'kape', 'Noun', 'Place', NULL),
('Bandara', 'Airport', '공항', 'gonghang', 'Noun', 'Place', NULL),
('Stasiun', 'Station', '역', 'yeok', 'Noun', 'Place', NULL);

-- Objects
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, sentence_pattern, base_verb) VALUES
('Nasi / Makanan', 'Rice / Meal', '밥', 'bap', 'Noun', 'O', NULL),
('Air', 'Water', '물', 'mul', 'Noun', 'O', NULL),
('Buku', 'Book', '책', 'chaek', 'Noun', 'O', NULL),
('Apel', 'Apple', '사과', 'sagwa', 'Noun', 'O', NULL),
('Roti', 'Bread', '빵', 'ppang', 'Noun', 'O', NULL),
('Susu', 'Milk', '우유', 'uyu', 'Noun', 'O', NULL),
('Kopi', 'Coffee', '커피', 'keopi', 'Noun', 'O', NULL),
('Teh', 'Tea', '차', 'cha', 'Noun', 'O', NULL),
('Film', 'Movie', '영화', 'yeonghwa', 'Noun', 'O', NULL),
('Musik', 'Music', '음악', 'eumak', 'Noun', 'O', NULL),
('Bahasa Korea', 'Korean Language', '한국어', 'hangugeo', 'Noun', 'O', NULL),
('Bahasa Indonesia', 'Indonesian Language', '인도네시아어', 'indonesia-eo', 'Noun', 'O', NULL),
('Bahasa Inggris', 'English Language', '영어', 'yeongeo', 'Noun', 'O', NULL),
('Baju / Pakaian', 'Clothes', '옷', 'ot', 'Noun', 'O', NULL),
('Surat', 'Letter', '편지', 'pyeonji', 'Noun', 'O', NULL),
('Mobil', 'Car', '자동차', 'jadongcha', 'Noun', 'O/Instrument', NULL),
('Kereta / Bus', 'Bus', '버스', 'beoseu', 'Noun', 'O/Instrument', NULL),
('Kereta Bawah Tanah', 'Subway', '지하철', 'jihacheol', 'Noun', 'O/Instrument', NULL),
('Sepeda', 'Bicycle', '자전거', 'jajeon-geo', 'Noun', 'O/Instrument', NULL),
('Pena / Pulpen', 'Pen', '펜', 'pen', 'Noun', 'O/Instrument', NULL),
('Sendok', 'Spoon', '숟가락', 'sutgarak', 'Noun', 'Instrument', NULL),
('Sumpit', 'Chopsticks', '젓가락', 'jeotgarak', 'Noun', 'Instrument', NULL),
('Ponsel / HP', 'Cell Phone', '핸드폰', 'haendeupon', 'Noun', 'O', NULL),
('Uang', 'Money', '돈', 'don', 'Noun', 'O', NULL);

-- Verbs (Predicates)
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, sentence_pattern, base_verb) VALUES
('Makan', 'Eat', '먹다', 'meokda', 'Verb', 'V', '먹다'),
('Minum', 'Drink', '마시다', 'masida', 'Verb', 'V', '마시다'),
('Membaca', 'Read', '읽다', 'ikda', 'Verb', 'V', '읽다'),
('Menulis', 'Write', '쓰다', 'sseuda', 'Verb', 'V', '쓰다'),
('Melihat / Menonton', 'See / Watch', '보다', 'boda', 'Verb', 'V', '보다'),
('Pergi', 'Go', '가다', 'gada', 'Verb', 'V', '가다'),
('Datang', 'Come', '오다', 'oda', 'Verb', 'V', '오다'),
('Belajar', 'Study', '공부하다', 'gongbuhada', 'Verb', 'V', '공부하다'),
('Bekerja', 'Work', '일하다', 'ilhada', 'Verb', 'V', '일하다'),
('Membeli', 'Buy', '사다', 'sada', 'Verb', 'V', '사다'),
('Menjual', 'Sell', '팔다', 'palda', 'Verb', 'V', '팔다'),
('Membuat', 'Make', '만들다', 'mandeulda', 'Verb', 'V', '만들다'),
('Mendengarkan', 'Listen', '듣다', 'deutda', 'Verb', 'V', '듣다'),
('Berbicara', 'Speak / Talk', '말하다', 'malhada', 'Verb', 'V', '말하다'),
('Bertemu', 'Meet', '만나다', 'mannada', 'Verb', 'V', '만나다'),
('Mengajar', 'Teach', '가르치다', 'gareuchida', 'Verb', 'V', '가르치다'),
('Tidur', 'Sleep', '자다', 'jada', 'Verb', 'V', '자다'),
('Bangun', 'Wake up', '일어나다', 'ireonada', 'Verb', 'V', '일어나다'),
('Beristirahat', 'Rest', '쉬다', 'swida', 'Verb', 'V', '쉬다'),
('Melakukan Olahraga', 'Exercise', '운동하다', 'undonghada', 'Verb', 'V', '운동하다'),
('Memasak', 'Cook', '요리하다', 'yorihada', 'Verb', 'V', '요리하다'),
('Menelepon', 'Call (Phone)', '전화하다', 'jeonhwahada', 'Verb', 'V', '전화하다'),
('Mencuci Tangan / Baju', 'Wash', '씻다', 'ssitda', 'Verb', 'V', '씻다');

-- Adjectives (Descriptive Verbs)
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, sentence_pattern, base_verb) VALUES
('Bagus / Baik', 'Good / Fine', '좋다', 'jota', 'Adjective', 'A', '좋다'),
('Buruk / Jelek', 'Bad', '나쁘다', 'nappeuda', 'Adjective', 'A', '나쁘다'),
('Banyak', 'Many / Much', '많다', 'manta', 'Adjective', 'A', '많다'),
('Sedikit', 'Few / Little', '적다', 'jeokda', 'Adjective', 'A', '적다'),
('Besar', 'Big / Large', '크다', 'keuda', 'Adjective', 'A', '크다'),
('Kecil', 'Small', '작다', 'jakda', 'Adjective', 'A', '작다'),
('Cantik / Indah', 'Pretty / Beautiful', '예쁘다', 'yeppeuda', 'Adjective', 'A', '예쁘다'),
('Menyenangkan / Menarik', 'Interesting / Fun', '재미있다', 'jaemiitda', 'Adjective', 'A', '재미있다'),
('Membosankan', 'Boring', '재미없다', 'jaemieopda', 'Adjective', 'A', '재미없다'),
('Enak / Lezat', 'Delicious', '맛있다', 'masitda', 'Adjective', 'A', '맛있다'),
('Tidak Enak', 'Not Delicious', '맛없다', 'madeopda', 'Adjective', 'A', '맛없다'),
('Sibuk', 'Busy', '바쁘다', 'bappeuda', 'Adjective', 'A', '바쁘다'),
('Dingin', 'Cold', '춥다', 'chupda', 'Adjective', 'A', '춥다'),
('Panas', 'Hot', '덥다', 'deopda', 'Adjective', 'A', '덥다'),
('Murah', 'Cheap', '싸다', 'ssada', 'Adjective', 'A', '싸다'),
('Mahal', 'Expensive', '비싸다', 'bissada', 'Adjective', 'A', '비싸다'),
('Cepat', 'Fast', '빠르다', 'ppareuda', 'Adjective', 'A', '빠르다'),
('Lambat', 'Slow', '느리다', 'neurida', 'Adjective', 'A', '느리다');

-- Particles
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, sentence_pattern, base_verb) VALUES
('Partikel Topik (Ada Batchim)', 'Topic Particle (Consonant)', '은', 'eun', 'Particle', 'Topic-C', NULL),
('Partikel Topik (Vokal)', 'Topic Particle (Vowel)', '는', 'neun', 'Particle', 'Topic-V', NULL),
('Partikel Subjek (Ada Batchim)', 'Subject Particle (Consonant)', '이', 'i', 'Particle', 'Subj-C', NULL),
('Partikel Subjek (Vokal)', 'Subject Particle (Vowel)', '가', 'ga', 'Particle', 'Subj-V', NULL),
('Partikel Objek (Ada Batchim)', 'Object Particle (Consonant)', '을', 'eul', 'Particle', 'Obj-C', NULL),
('Partikel Objek (Vokal)', 'Object Particle (Vowel)', '를', 'reul', 'Particle', 'Obj-V', NULL),
('Partikel Tempat Aktivitas (Di)', 'Action Location (At/In)', '에서', 'eseo', 'Particle', 'Loc-Action', NULL),
('Partikel Tempat Keberadaan/Waktu/Tujuan (Di/Ke)', 'Location / Time / To', '에', 'e', 'Particle', 'Loc-Static/Time', NULL),
('Partikel Sarana/Arah (Dengan/Lewat)', 'Instrument / By / Toward', '으로 / 로', 'euro / ro', 'Particle', 'Instrument', NULL);

-- Common Expressions / Phrases
INSERT INTO dictionary (indonesian, english, korean_hangul, korean_roman, pos, sentence_pattern, base_verb) VALUES
('Halo / Apa kabar?', 'Hello / How are you?', '안녕하세요', 'annyeonghaseyo', 'Phrase', 'Greeting', NULL),
('Terima kasih', 'Thank you', '감사합니다', 'gamsahamnida', 'Phrase', 'Courtesy', NULL),
('Terima kasih (Biasa)', 'Thank you (Informal Polite)', '고마워요', 'gomawoyo', 'Phrase', 'Courtesy', NULL),
('Sama-sama', 'You are welcome', '천만에요', 'cheonman-eyo', 'Phrase', 'Courtesy', NULL),
('Maaf / Permisi', 'Sorry / Excuse me', '죄송합니다', 'joesonghamnida', 'Phrase', 'Courtesy', NULL),
('Selamat tinggal (Untuk yang pergi)', 'Goodbye (To someone leaving)', '안녕히 가세요', 'annyeonghi gaseyo', 'Phrase', 'Greeting', NULL),
('Selamat tinggal (Untuk yang tinggal)', 'Goodbye (To someone staying)', '안녕히 계세요', 'annyeonghi gyeseyo', 'Phrase', 'Greeting', NULL),
('Senang bertemu denganmu', 'Nice to meet you', '만나서 반갑습니다', 'mannaseo bangapseumnida', 'Phrase', 'Greeting', NULL),
('Ya', 'Yes', '네', 'ne', 'Phrase', 'Response', NULL),
('Tidak / Bukan', 'No / Not', '아니요', 'aniyo', 'Phrase', 'Response', NULL),
('Tolong bantu saya', 'Please help me', '도와주세요', 'dowajuseyo', 'Phrase', 'Request', NULL),
('Selamat makan', 'Bon appetit / I will eat well', '잘 먹겠습니다', 'jal meokgetseumnida', 'Phrase', 'Expression', NULL),
('Terima kasih atas makanannya', 'Thank you for the meal', '잘 먹었습니다', 'jal meogeotseumnida', 'Phrase', 'Expression', NULL);

-- ================================================================
-- SEED DATA: EXAM PACKAGES (LEVEL 1 s.d. 4)
-- ================================================================
INSERT INTO exam_packages (id, title, level, total_questions) VALUES
(1, 'Level 1: Dasar Hangeul & Partikel', 1, 5),
(2, 'Level 2: Struktur Kalimat SOV & Arah', 2, 5),
(3, 'Level 3: Konjugasi Sopan & Kehidupan Sehari-hari', 3, 5),
(4, 'Level 4: TOPIK I Mastery & Tata Bahasa Lanjutan', 4, 5);

-- ================================================================
-- SEED DATA: EXAM QUESTIONS
-- ================================================================

-- LEVEL 1: Dasar Hangeul & Partikel
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(1, 'particle_topic', 'Pilihlah partikel topik yang tepat untuk kata: "선생님" (Guru)', '선생님은 한국어를 가르칩니다.', '은', '는', '이', '를', 'A', 'Kata "선생님" memiliki konsonan akhir/batchim (ㅁ), sehingga partikel topik yang wajib digunakan adalah "은".', 'The word "선생님" ends with a batchim (final consonant ㅁ), so it requires the topic particle "은".'),
(1, 'particle_object', 'Pilihlah partikel objek yang benar untuk kalimat: "저는 사과___ 먹어요" (Saya makan apel).', '저는 사과를 먹어요.', '을', '를', '은', '가', 'B', 'Kata "사과" berakhiran huruf vokal (ㅘ) tanpa batchim, maka menggunakan partikel objek "를".', 'The word "사과" ends with a vowel (without batchim), so the object particle "를" is used.'),
(1, 'spelling_batchim', 'Manakah di antara suku kata berikut yang TIDAK memiliki batchim (konsonan akhir)?', '사과', '밥', '책', '사', '집', 'C', 'Suku kata "사" (ㅅ + ㅏ) tidak memiliki konsonan akhir (jongseong=0), sedangkan 밥 (ㅂ), 책 (ㄱ), dan 집 (ㅂ) semuanya memiliki batchim.', 'The syllable "사" has no final consonant (batchim), while 밥, 책, and 집 all have batchims.'),
(1, 'particle_subject', 'Isilah titik-titik dengan partikel subjek yang tepat: "날씨___ 좋아요" (Cuacanya bagus).', '날씨가 좋아요.', '이', '가', '을', '는', 'B', 'Kata "날씨" berakhiran huruf vokal (ㅣ) tanpa batchim, sehingga partikel subjek yang digunakan adalah "가".', 'The word "날씨" ends with a vowel (ㅣ), so the subject particle "가" is selected.'),
(1, 'particle_location', 'Untuk menyatakan tempat terjadinya suatu kegiatan aktif ("di perpustakaan belajar"), partikel apa yang dipakai?', '도서관에서 공부해요.', '에', '에서', '으로', '를', 'B', 'Partikel "에서" digunakan untuk menandai lokasi di mana suatu aksi aktif sedang berlangsung.', 'The particle "에서" marks the dynamic location where an action takes place.');

-- LEVEL 2: Struktur Kalimat SOV & Arah
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(2, 'sov_structure', 'Bagaimana susunan SOV bahasa Korea untuk kalimat: "Budi membaca buku"?', '부디는 책을 읽어요.', '부디는 읽어요 책을', '부디는 책을 읽어요', '책을 부디는 읽어요', '읽어요 부디는 책을', 'B', 'Struktur baku bahasa Korea adalah Subjek (부디는) + Objek (책을) + Predikat (읽어요).', 'Standard Korean sentence structure follows Subject (부디는) + Object (책을) + Predicate (읽어요).'),
(2, 'particle_direction', 'Lengkapilah kalimat menuju tujuan: "저는 내일 학교___ 가요" (Saya besok pergi ke sekolah).', '저는 내일 학교에 가요.', '에', '에서', '을', '으로', 'A', 'Kata kerja perpindahan/arah seperti 가다 (pergi) dan 오다 (datang) berpasangan dengan partikel tujuan "에".', 'Movement verbs like 가다 (to go) and 오다 (to come) pair with the destination particle "에".'),
(2, 'instrument_rieul', 'Pilihlah partikel sarana/alat yang benar: "지하철___ 가요" (Pergi dengan subway).', '지하철로 가요.', '으로', '로', '에서', '에', 'B', 'Perhatian! Kata "지하철" berakhiran batchim "ㄹ". Sesuai aturan fonologi Korea, kata berakhiran vokal ATAU batchim "ㄹ" menggunakan "로" (bukan 으로).', 'Note! "지하철" ends with the batchim "ㄹ". According to Korean phonology, words ending in a vowel OR batchim "ㄹ" take "로".'),
(2, 'sov_translation', 'Terjemahkan secara tepat: "Saya minum air di rumah."', '저는 집에서 물을 마셔요.', '저는 마셔요 집에서 물을', '저는 집에서 물을 마셔요', '저는 물을 집에서 마셔요', '집에서 저는 마셔요 물을', 'B', 'Pola kalimat bahasa Korea yang paling alami adalah Subjek (저는) + Keterangan Tempat (집에서) + Objek (물을) + Predikat (마셔요).', 'The natural Korean structure is Subject (저는) + Place (집에서) + Object (물을) + Verb (마셔요).'),
(2, 'particle_instrument', 'Gunakan partikel sarana yang tepat: "연필___ 글씨를 써요" (Menulis huruf dengan pensil).', '연필로 글씨를 써요.', '으로', '로', '에', '을', 'B', 'Kata "연필" berakhiran batchim "ㄹ", sehingga menggunakan "로".', 'The word "연필" ends with batchim "ㄹ", thus takes "로".');

-- LEVEL 3: Konjugasi Sopan & Kehidupan Sehari-hari
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(3, 'conjugation_informal', 'Bagaimana konjugasi bentuk informal sopan (-아요/어요) dari kata kerja "먹다" (makan)?', '먹어요', '먹아요', '먹어요', '먹해요', '먹습니다', 'B', 'Vokal dasar kata kerja "먹다" adalah "ㅓ" (bukan ㅏ/ㅗ), sehingga dilekatkan akhiran "-어요" menjadi "먹어요".', 'The stem vowel of "먹다" is "ㅓ" (not ㅏ/ㅗ), so it attaches "-어요" becoming "먹어요".'),
(3, 'conjugation_hada', 'Bentuk informal sopan dari kata kerja "공부하다" (belajar) adalah...', '공부해요', '공부하요', '공부해요', '공부했어요', '공부합니다', 'B', 'Semua kata kerja berakhiran "하다" berubah menjadi "해요" dalam bentuk informal sopan sekarang.', 'All verbs ending with "하다" conjugate to "해요" in the present informal polite style.'),
(3, 'conjugation_formal', 'Ubahlah kata kerja "가다" (pergi) ke dalam bentuk formal sopan (-ㅂ니다/습니다):', '갑니다', '가습니다', '갑니다', '가요', '갔습니다', 'B', 'Akar kata "가" tidak memiliki batchim (berakhiran vokal), maka langsung digabung dengan "-ㅂ니다" menjadi "갑니다".', 'The verb stem "가" has no batchim, so "-ㅂ니다" is attached directly, forming "갑니다".'),
(3, 'conjugation_past', 'Manakah bentuk lampau (-았/었어요) yang benar dari "보다" (melihat)?', '봤어요', '보았어요 / 봤어요', '보었어요', '보해요', '봅니다', 'A', 'Vokal akar kata "ㅗ" berkontraksi dengan "ㅏ" membentuk "ㅘ" lampau: 보 + 았어요 = 봤어요.', 'The stem vowel "ㅗ" combines with "ㅏ" into "ㅘ" past tense: 보 + 았어요 = 봤어요.'),
(3, 'honorific_polite', 'Pilihlah bentuk formal sopan dari kata sifat "좋다" (bagus):', '좋습니다', '좋습니다', '좋ㅂ니다', '좋아요', '좋았습니다', 'A', 'Akar kata "좋" memiliki batchim (ㅎ), sehingga dilekatkan akhiran "-습니다" menjadi "좋습니다".', 'The stem "좋" has a batchim (ㅎ), so "-습니다" is attached, resulting in "좋습니다".');

-- LEVEL 4: TOPIK I Mastery & Tata Bahasa Lanjutan
INSERT INTO exam_questions (package_id, type, question, hangul_audio_text, option_a, option_b, option_c, option_d, correct_answer, explanation_id, explanation_en) VALUES
(4, 'reading_comprehension', 'Bacalah percakapan: 가: "어디에 가요?" / 나: "도서관에 가요. 책을 ___."', '도서관에 가요. 책을 읽어요.', '마셔요', '읽어요', '자요', '만나요', 'B', 'Konteks pergi ke perpustakaan (도서관) berpasangan logis dengan membaca buku (책을 읽어요).', 'Going to the library (도서관) logically connects with reading a book (책을 읽어요).'),
(4, 'irregular_rieul', 'Konjugasikan kata kerja tidak beraturan "만들다" (membuat) ke dalam bentuk formal (-ㅂ니다/습니다):', '만듭니다', '만들습니다', '만듭니다', '만들ㅂ니다', '만들어요', 'B', 'Aturan tidak beraturan "ㄹ": saat bertemu dengan akhiran berawalan ㄴ, ㅂ, ㅅ, konsonan "ㄹ" gugur sehingga 만들다 menjadi "만듭니다".', 'The "ㄹ" irregular rule: when followed by endings starting with ㄴ, ㅂ, or ㅅ, the "ㄹ" drops, turning 만들다 into "만듭니다".'),
(4, 'future_intention', 'Pilihlah bentuk rencana/masa depan (-(으)ㄹ 거예요) untuk "먹다":', '먹을 거예요', '먹ㄹ 거예요', '먹을 거예요', '먹겠어요', '먹는 거예요', 'B', 'Akar kata "먹" berakhiran batchim (ㄱ), sehingga menggunakan "-을 거예요" menjadi "먹을 거예요".', 'The stem "먹" has a batchim (ㄱ), requiring "-을 거예요" to form "먹을 거예요".'),
(4, 'particle_contrast', 'Lengkapi dengan partikel pembanding yang tepat: "사과는 맛있어요. 하지만 바나나___ 맛없어요."', '사과는 맛있어요. 하지만 바나나는 맛없어요.', '가', '는', '를', '도', 'B', 'Partikel topik "는/은" sering digunakan untuk memberikan fungsi kontras/pembanding antara dua hal (apel vs pisang).', 'The topic particle "는/은" is commonly used to express contrast between two items (apple vs banana).'),
(4, 'time_particle', 'Pilihlah partikel penanda waktu yang benar: "저는 아침 8시___ 일어나요" (Saya bangun pada jam 8 pagi).', '저는 아침 8시에 일어나요.', '에', '에서', '을', '로', 'A', 'Waktu spesifik (jam, tanggal, hari) ditandai dengan partikel "에".', 'Specific times (hours, days, dates) are marked by the time particle "에".');
