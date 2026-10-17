import 'hangul_speller.dart';

/// Conjugation Formality Style
enum FormalityLevel {
  informalPolite, // -아요 / -어요 / -해요 (Haeyo-che, polite everyday)
  formalPolite,   // -ㅂ니다 / -습니다 (Hasipsio-che, formal public)
  pastTense,      // -았어요 / -었어요 / -했어요
  futureTense,    // -(으)ㄹ 거예요
  baseDictionary, // -다 (Root form)
}

/// Grammar Role in Korean SOV Sentence Structure
enum GrammarRole {
  subject,    // 주어 (S)
  time,       // 시간 (Time)
  location,   // 처소/장소 (Place / Where)
  instrument, // 수단/도구 (By / With / Instrument)
  object,     // 목적어 (O)
  predicate,  // 서술어 (V / Predicate / Verb / Adjective)
  standalone, // 독립어 / 단어 (Standalone Word / Phrase)
}

/// An analyzed grammar token holding Korean, particles, and grammatical explanations.
class GrammarToken {
  final GrammarRole role;
  final String label;          // e.g. "Subjek", "Keterangan Tempat", "Objek", "Predikat"
  final String originalText;   // ID/EN input text (e.g. "Saya", "Di rumah", "Nasi", "Makan")
  final String koreanCore;     // Korean word without particle (e.g. "저", "집", "밥", "먹다")
  final String? particle;      // Attached particle (e.g. "는", "에서", "을")
  final String fullKorean;     // Combined text (e.g. "저는", "집에서", "밥을", "먹어요")
  final String romanization;   // Romanized Korean
  final String explanation;    // Bilingual explanation of batchim and particle choice
  final bool hasBatchim;       // Batchim status of core word
  final String? spellingFormula; // [ㄱ + ㅏ + ㅁ = 감]

  const GrammarToken({
    required this.role,
    required this.label,
    required this.originalText,
    required this.koreanCore,
    this.particle,
    required this.fullKorean,
    required this.romanization,
    required this.explanation,
    required this.hasBatchim,
    this.spellingFormula,
  });
}

/// Full result of Korean Grammar Engine parsing and conjugation.
class GrammarSentenceResult {
  final String originalInput;
  final String detectedLanguage; // 'id' or 'en'
  final List<GrammarToken> tokens; // SOV tokens ordered
  final String sovPattern; // e.g. "S - L - O - V" or "Kosakata Tunggal"
  final String informalSentence; // -아요/어요
  final String formalSentence;   // -ㅂ니다/습니다
  final String pastSentence;     // -았/었어요
  final String futureSentence;   // -(으)ㄹ 거예요
  final String baseSentence;     // Root form
  final String fullSpellingFormula;
  final String grammaticalSummary;

  const GrammarSentenceResult({
    required this.originalInput,
    required this.detectedLanguage,
    required this.tokens,
    required this.sovPattern,
    required this.informalSentence,
    required this.formalSentence,
    required this.pastSentence,
    required this.futureSentence,
    required this.baseSentence,
    required this.fullSpellingFormula,
    required this.grammaticalSummary,
  });

  String getSentenceByFormality(FormalityLevel level) {
    switch (level) {
      case FormalityLevel.informalPolite:
        return informalSentence;
      case FormalityLevel.formalPolite:
        return formalSentence;
      case FormalityLevel.pastTense:
        return pastSentence;
      case FormalityLevel.futureTense:
        return futureSentence;
      case FormalityLevel.baseDictionary:
        return baseSentence;
    }
  }

  String getRomanizationByFormality(FormalityLevel level) {
    final sentence = getSentenceByFormality(level);
    return HangulSpeller.romanizeText(sentence);
  }
}

/// High-performance deterministic rule-based Korean grammar processor.
/// Operates 100% offline with zero runtime battery and CPU overhead.
class KoreanGrammarEngine {
  KoreanGrammarEngine._();

  // --------------------------------------------------------------------------
  // PREDICATE CONJUGATION ENGINE
  // --------------------------------------------------------------------------

  /// Conjugates a base Korean verb or adjective stem into informal polite (-아요/어요/해요).
  static String conjugateInformalPolite(String baseVerb) {
    if (!baseVerb.endsWith('다')) return baseVerb;
    final stem = baseVerb.substring(0, baseVerb.length - 1);
    if (stem.isEmpty) return baseVerb;

    // Special case 1: -하다 verbs
    if (stem.endsWith('하')) {
      final prefix = stem.substring(0, stem.length - 1);
      return '$prefix해요';
    }

    // Special case 2: Irregular/Contracted forms
    if (stem == '보') return '봐요';
    if (stem == '오') return '와요';
    if (stem == '가') return '가요';
    if (stem == '자') return '자요';
    if (stem == '사') return '사요';
    if (stem == '만나') return '만나요';
    if (stem == '타') return '타요';
    if (stem == '쓰') return '써요';
    if (stem == '크') return '커요';
    if (stem == '예쁘') return '예뻐요';
    if (stem == '바쁘') return '바빠요';
    if (stem == '아프') return '아파요';
    if (stem == '마시') return '마셔요';
    if (stem == '가르치') return '가르쳐요';
    if (stem == '기다리') return '기다려요';
    if (stem == '배우') return '배워요';
    if (stem == '주') return '줘요';
    if (stem == '쉬') return '쉬어요';

    // Irregular 'ㅂ': 춥다 -> 추워요, 덥다 -> 더워요, 어렵다 -> 어려워요, 쉽다 -> 쉬워요
    if (stem.endsWith('춥')) return '추워요';
    if (stem.endsWith('덥')) return '더워요';
    if (stem.endsWith('어렵')) return '어려워요';
    if (stem.endsWith('쉽')) return '쉬워요';
    if (stem.endsWith('맵')) return '매워요';
    if (stem.endsWith('고맙')) return '고마워요';
    if (stem.endsWith('반갑')) return '반가워요';

    // Irregular 'ㄷ': 듣다 -> 들어요, 걷다 -> 걸어요
    if (stem == '듣') return '들어요';
    if (stem == '걷') return '걸어요';

    // Inspect last syllable of stem
    final lastChar = stem[stem.length - 1];
    final decomp = HangulSpeller.decomposeChar(lastChar);
    if (decomp == null) return '$stem어요';

    // Has batchim?
    if (decomp.hasBatchim) {
      // Vowel harmony: ㅏ (index 0) or ㅗ (index 8) -> + 아요
      if (decomp.jungseongIndex == 0 || decomp.jungseongIndex == 8) {
        return '$stem아요';
      } else {
        return '$stem어요';
      }
    } else {
      return '$stem어요';
    }
  }

  /// Conjugates a base Korean verb or adjective stem into formal polite (-ㅂ니다/습니다).
  static String conjugateFormalPolite(String baseVerb) {
    if (!baseVerb.endsWith('다')) return baseVerb;
    final stem = baseVerb.substring(0, baseVerb.length - 1);
    if (stem.isEmpty) return baseVerb;

    // Irregular 'ㄹ': 만들다 -> 만듭니다, 살다 -> 삽니다, 팔다 -> 팝니다
    if (HangulSpeller.endsWithRieulBatchim(stem)) {
      final lastChar = stem[stem.length - 1];
      final decomp = HangulSpeller.decomposeChar(lastChar);
      if (decomp != null) {
        final prefix = stem.substring(0, stem.length - 1);
        final newChar = HangulSpeller.composeChar(
          decomp.choseongIndex,
          decomp.jungseongIndex,
          17, // index of ㅂ in jongseongList
        );
        return '$prefix$newChar니다';
      }
    }

    final hasBatchim = HangulSpeller.hasBatchim(stem);
    if (hasBatchim) {
      return '$stem습니다';
    } else {
      final lastChar = stem[stem.length - 1];
      final decomp = HangulSpeller.decomposeChar(lastChar);
      if (decomp != null && !decomp.hasBatchim) {
        final prefix = stem.substring(0, stem.length - 1);
        final newChar = HangulSpeller.composeChar(
          decomp.choseongIndex,
          decomp.jungseongIndex,
          17, // 'ㅂ' batchim index
        );
        return '$prefix$newChar니다';
      }
      return '$stemㅂ니다';
    }
  }

  /// Conjugates a base verb into past tense (-았어요 / -었어요 / -했어요).
  static String conjugatePastTense(String baseVerb) {
    if (!baseVerb.endsWith('다')) return baseVerb;
    final stem = baseVerb.substring(0, baseVerb.length - 1);
    if (stem.isEmpty) return baseVerb;

    if (stem.endsWith('하')) {
      final prefix = stem.substring(0, stem.length - 1);
      return '$prefix했어요';
    }
    if (stem == '보') return '봤어요';
    if (stem == '오') return '왔어요';
    if (stem == '가') return '갔어요';
    if (stem == '자') return '잤어요';
    if (stem == '사') return '샀어요';
    if (stem == '만나') return '만났어요';
    if (stem == '쓰') return '썼어요';
    if (stem == '마시') return '마셨어요';
    if (stem == '배우') return '배웠어요';
    if (stem == '크') return '컸어요';
    if (stem == '예쁘') return '예뻤어요';

    if (stem.endsWith('춥')) return '추웠어요';
    if (stem.endsWith('덥')) return '더웠어요';
    if (stem.endsWith('어렵')) return '어려웠어요';
    if (stem.endsWith('쉽')) return '쉬웠어요';
    if (stem.endsWith('듣')) return '들었어요';

    final lastChar = stem[stem.length - 1];
    final decomp = HangulSpeller.decomposeChar(lastChar);
    if (decomp == null) return '$stem었어요';

    if (decomp.hasBatchim) {
      if (decomp.jungseongIndex == 0 || decomp.jungseongIndex == 8) {
        return '$stem았어요';
      } else {
        return '$stem었어요';
      }
    } else {
      return '$stem었어요';
    }
  }

  /// Conjugates a base verb into future intention (-(으)ㄹ 거예요).
  static String conjugateFutureTense(String baseVerb) {
    if (!baseVerb.endsWith('다')) return baseVerb;
    final stem = baseVerb.substring(0, baseVerb.length - 1);
    if (stem.isEmpty) return baseVerb;

    if (HangulSpeller.endsWithRieulBatchim(stem)) {
      return '$stem 거예요';
    }

    final hasBatchim = HangulSpeller.hasBatchim(stem);
    if (hasBatchim) {
      return '$stem을 거예요';
    } else {
      final lastChar = stem[stem.length - 1];
      final decomp = HangulSpeller.decomposeChar(lastChar);
      if (decomp != null && !decomp.hasBatchim) {
        final prefix = stem.substring(0, stem.length - 1);
        final newChar = HangulSpeller.composeChar(
          decomp.choseongIndex,
          decomp.jungseongIndex,
          8, // 'ㄹ' batchim index
        );
        return '$prefix$newChar 거예요';
      }
      return '$stemㄹ 거예요';
    }
  }

  // --------------------------------------------------------------------------
  // EXTENSIVE VOCABULARY LEXICON
  // --------------------------------------------------------------------------

  static final Map<String, _SubjectInfo> _subjects = {
    'saya': _SubjectInfo('저', 'Saya (sopan)', false),
    'aku': _SubjectInfo('나', 'Aku (akrab)', false),
    'i': _SubjectInfo('저', 'I', false),
    'me': _SubjectInfo('저', 'Me', false),
    'kamu': _SubjectInfo('너', 'Kamu (akrab)', false),
    'anda': _SubjectInfo('당신', 'Anda (sopan)', true),
    'you': _SubjectInfo('당신', 'You', true),
    'dia': _SubjectInfo('그 사람', 'Dia', true),
    'kami': _SubjectInfo('우리', 'Kami / Kita', false),
    'kita': _SubjectInfo('우리', 'Kita', false),
    'we': _SubjectInfo('우리', 'We', false),
    'mereka': _SubjectInfo('그들', 'Mereka', true),
    'they': _SubjectInfo('그들', 'They', true),
    'budi': _SubjectInfo('부디', 'Budi', false),
    'minho': _SubjectInfo('민호', 'Minho', false),
    'andi': _SubjectInfo('안디', 'Andi', false),
    'siti': _SubjectInfo('시티', 'Siti', false),
    'rudi': _SubjectInfo('루디', 'Rudi', false),
    'tuan': _SubjectInfo('투안', 'Tuan', true),
    'rihan': _SubjectInfo('리한', 'Rihan', true),
    'guru': _SubjectInfo('선생님', 'Guru', true),
    'teacher': _SubjectInfo('선생님', 'Teacher', true),
    'siswa': _SubjectInfo('학생', 'Siswa / Murid', true),
    'murid': _SubjectInfo('학생', 'Murid', true),
    'student': _SubjectInfo('학생', 'Student', true),
    'teman': _SubjectInfo('친구', 'Teman', false),
    'sahabat': _SubjectInfo('친구', 'Sahabat', false),
    'friend': _SubjectInfo('친구', 'Friend', false),
    'ibu': _SubjectInfo('어머니', 'Ibu', false),
    'mother': _SubjectInfo('어머니', 'Mother', false),
    'mama': _SubjectInfo('어머니', 'Mama', false),
    'ayah': _SubjectInfo('아버지', 'Ayah', false),
    'father': _SubjectInfo('아버지', 'Father', false),
    'papa': _SubjectInfo('아버지', 'Papa', false),
    'adik': _SubjectInfo('동생', 'Adik', true),
    'kakak': _SubjectInfo('형', 'Kakak', true),
    'abang': _SubjectInfo('형', 'Abang', true),
    'mahasiswa': _SubjectInfo('대학생', 'Mahasiswa', true),
    'pegawai': _SubjectInfo('회사원', 'Pegawai kantor', true),
    'karyawan': _SubjectInfo('회사원', 'Karyawan', true),
    'pekerja': _SubjectInfo('근로자', 'Pekerja pabrik', false),
    'dokter': _SubjectInfo('의사', 'Dokter', false),
    'polisi': _SubjectInfo('경찰', 'Polisi', true),
    'bos': _SubjectInfo('사장님', 'Pimpinan / Bos', true),
    'mandor': _SubjectInfo('반장님', 'Mandor', true),
  };

  static final Map<String, _PlaceInfo> _places = {
    'rumah': _PlaceInfo('집', 'Rumah', true),
    'home': _PlaceInfo('집', 'Home', true),
    'house': _PlaceInfo('집', 'House', true),
    'kamar': _PlaceInfo('방', 'Kamar', true),
    'asrama': _PlaceInfo('기숙사', 'Asrama', false),
    'sekolah': _PlaceInfo('학교', 'Sekolah', false),
    'school': _PlaceInfo('학교', 'School', false),
    'universitas': _PlaceInfo('대학교', 'Universitas', false),
    'kampus': _PlaceInfo('대학교', 'Kampus', false),
    'university': _PlaceInfo('대학교', 'University', false),
    'perpustakaan': _PlaceInfo('도서관', 'Perpustakaan', true),
    'library': _PlaceInfo('도서관', 'Library', true),
    'restoran': _PlaceInfo('식당', 'Restoran / Kantin', true),
    'restaurant': _PlaceInfo('식당', 'Restaurant', true),
    'kantin': _PlaceInfo('식당', 'Kantin', true),
    'kantor': _PlaceInfo('사무실', 'Kantor', true),
    'office': _PlaceInfo('사무실', 'Office', true),
    'perusahaan': _PlaceInfo('회사', 'Perusahaan / Pabrik', false),
    'pabrik': _PlaceInfo('공장', 'Pabrik', true),
    'toko': _PlaceInfo('가게', 'Toko', false),
    'pasar': _PlaceInfo('시장', 'Pasar', true),
    'market': _PlaceInfo('시장', 'Market', true),
    'supermarket': _PlaceInfo('마트', 'Supermarket', false),
    'mart': _PlaceInfo('마트', 'Supermarket', false),
    'minimarket': _PlaceInfo('편의점', 'Minimarket', true),
    'apotek': _PlaceInfo('약국', 'Apotek', true),
    'pharmacy': _PlaceInfo('약국', 'Pharmacy', true),
    'rumah sakit': _PlaceInfo('병원', 'Rumah Sakit', true),
    'hospital': _PlaceInfo('병원', 'Hospital', true),
    'bank': _PlaceInfo('은행', 'Bank', true),
    'stasiun': _PlaceInfo('역', 'Stasiun', true),
    'station': _PlaceInfo('역', 'Station', true),
    'halte': _PlaceInfo('정류장', 'Halte bus', true),
    'bandara': _PlaceInfo('공항', 'Bandara udara', true),
    'airport': _PlaceInfo('공항', 'Airport', true),
    'taman': _PlaceInfo('공원', 'Taman', true),
    'park': _PlaceInfo('공원', 'Park', true),
    'kafe': _PlaceInfo('카페', 'Kafe', false),
    'cafe': _PlaceInfo('카페', 'Cafe', false),
    'bioskop': _PlaceInfo('영화관', 'Bioskop', true),
    'hotel': _PlaceInfo('호텔', 'Hotel', true),
    'korea': _PlaceInfo('한국', 'Korea', true),
    'seoul': _PlaceInfo('서울', 'Seoul', true),
    'indonesia': _PlaceInfo('인도네시아', 'Indonesia', false),
    'jakarta': _PlaceInfo('자카르타', 'Jakarta', false),
  };

  static final Map<String, _ObjectInfo> _objects = {
    'nasi': _ObjectInfo('밥', 'Nasi / Makanan', true),
    'makanan': _ObjectInfo('음식', 'Makanan', true),
    'rice': _ObjectInfo('밥', 'Rice', true),
    'air': _ObjectInfo('물', 'Air putih', true),
    'water': _ObjectInfo('물', 'Water', true),
    'buku': _ObjectInfo('책', 'Buku', true),
    'book': _ObjectInfo('책', 'Book', true),
    'roti': _ObjectInfo('빵', 'Roti', true),
    'bread': _ObjectInfo('빵', 'Bread', true),
    'apel': _ObjectInfo('사과', 'Apel', false),
    'apple': _ObjectInfo('사과', 'Apple', false),
    'pisang': _ObjectInfo('바나나', 'Pisang', false),
    'jeruk': _ObjectInfo('오렌지', 'Jeruk', false),
    'susu': _ObjectInfo('우유', 'Susu', false),
    'milk': _ObjectInfo('우유', 'Milk', false),
    'kopi': _ObjectInfo('커피', 'Kopi', false),
    'coffee': _ObjectInfo('커피', 'Coffee', false),
    'teh': _ObjectInfo('차', 'Teh', false),
    'tea': _ObjectInfo('차', 'Tea', false),
    'daging': _ObjectInfo('고기', 'Daging', false),
    'ikan': _ObjectInfo('생선', 'Ikan', true),
    'ayam': _ObjectInfo('닭고기', 'Daging ayam', false),
    'mie': _ObjectInfo('라면', 'Mie instan / Ramen', true),
    'pizza': _ObjectInfo('피자', 'Pizza', false),
    'kimchi': _ObjectInfo('김치', 'Kimchi', false),
    'obat': _ObjectInfo('약', 'Obat', true),
    'medicine': _ObjectInfo('약', 'Medicine', true),
    'film': _ObjectInfo('영화', 'Film', false),
    'movie': _ObjectInfo('영화', 'Movie', false),
    'musik': _ObjectInfo('음악', 'Musik', true),
    'music': _ObjectInfo('음악', 'Music', true),
    'lagu': _ObjectInfo('노래', 'Lagu', false),
    'drama': _ObjectInfo('드라마', 'Drama', false),
    'bahasa korea': _ObjectInfo('한국어', 'Bahasa Korea', false),
    'korean': _ObjectInfo('한국어', 'Korean language', false),
    'bahasa indonesia': _ObjectInfo('인도네시아어', 'Bahasa Indonesia', false),
    'bahasa inggris': _ObjectInfo('영어', 'Bahasa Inggris', false),
    'baju': _ObjectInfo('옷', 'Baju pakaian', true),
    'pakaian': _ObjectInfo('옷', 'Pakaian', true),
    'celana': _ObjectInfo('바지', 'Celana', false),
    'sepatu': _ObjectInfo('신발', 'Sepatu', true),
    'topi': _ObjectInfo('모자', 'Topi', false),
    'tas': _ObjectInfo('가방', 'Tas', true),
    'surat': _ObjectInfo('편지', 'Surat', false),
    'uang': _ObjectInfo('돈', 'Uang', true),
    'money': _ObjectInfo('돈', 'Money', true),
    'dompet': _ObjectInfo('지갑', 'Dompet', true),
    'kunci': _ObjectInfo('열쇠', 'Kunci', false),
    'ponsel': _ObjectInfo('핸드폰', 'Ponsel / HP', true),
    'hp': _ObjectInfo('핸드폰', 'HP', true),
    'komputer': _ObjectInfo('컴퓨터', 'Komputer', false),
    'laptop': _ObjectInfo('노트북', 'Laptop', true),
    'televisi': _ObjectInfo('텔레비전', 'Televisi / TV', true),
    'tv': _ObjectInfo('텔레비전', 'TV', true),
    'mobil': _ObjectInfo('자동차', 'Mobil', false),
    'sepeda': _ObjectInfo('자전거', 'Sepeda', false),
  };

  static final Map<String, _VerbInfo> _verbs = {
    'makan': _VerbInfo('먹다', 'Makan', 'meokda'),
    'eat': _VerbInfo('먹다', 'Eat', 'meokda'),
    'eats': _VerbInfo('먹다', 'Eat', 'meokda'),
    'minum': _VerbInfo('마시다', 'Minum', 'masida'),
    'drink': _VerbInfo('마시다', 'Drink', 'masida'),
    'drinks': _VerbInfo('마시다', 'Drink', 'masida'),
    'membaca': _VerbInfo('읽다', 'Membaca', 'ikda'),
    'baca': _VerbInfo('읽다', 'Membaca', 'ikda'),
    'read': _VerbInfo('읽다', 'Read', 'ikda'),
    'reads': _VerbInfo('읽다', 'Read', 'ikda'),
    'menulis': _VerbInfo('쓰다', 'Menulis', 'sseuda'),
    'tulis': _VerbInfo('쓰다', 'Menulis', 'sseuda'),
    'write': _VerbInfo('쓰다', 'Write', 'sseuda'),
    'melihat': _VerbInfo('보다', 'Melihat', 'boda'),
    'menonton': _VerbInfo('보다', 'Menonton', 'boda'),
    'nonton': _VerbInfo('보다', 'Menonton', 'boda'),
    'lihat': _VerbInfo('보다', 'Melihat', 'boda'),
    'watch': _VerbInfo('보다', 'Watch', 'boda'),
    'see': _VerbInfo('보다', 'See', 'boda'),
    'mendengarkan': _VerbInfo('듣다', 'Mendengarkan', 'deutda'),
    'mendengar': _VerbInfo('듣다', 'Mendengar', 'deutda'),
    'dengar': _VerbInfo('듣다', 'Mendengar', 'deutda'),
    'listen': _VerbInfo('듣다', 'Listen', 'deutda'),
    'pergi': _VerbInfo('가다', 'Pergi', 'gada'),
    'go': _VerbInfo('가다', 'Go', 'gada'),
    'goes': _VerbInfo('가다', 'Go', 'gada'),
    'datang': _VerbInfo('오다', 'Datang', 'oda'),
    'come': _VerbInfo('오다', 'Come', 'oda'),
    'pulang': _VerbInfo('돌아가다', 'Pulang', 'doragada'),
    'belajar': _VerbInfo('공부하다', 'Belajar', 'gongbuhada'),
    'study': _VerbInfo('공부하다', 'Study', 'gongbuhada'),
    'mengajar': _VerbInfo('가르치다', 'Mengajar', 'gareuchida'),
    'bekerja': _VerbInfo('일하다', 'Bekerja', 'ilhada'),
    'kerja': _VerbInfo('일하다', 'Bekerja', 'ilhada'),
    'work': _VerbInfo('일하다', 'Work', 'ilhada'),
    'membeli': _VerbInfo('사다', 'Membeli', 'sada'),
    'beli': _VerbInfo('사다', 'Membeli', 'sada'),
    'buy': _VerbInfo('사다', 'Buy', 'sada'),
    'menjual': _VerbInfo('팔다', 'Menjual', 'palda'),
    'jual': _VerbInfo('팔다', 'Menjual', 'palda'),
    'membuat': _VerbInfo('만들다', 'Membuat', 'mandeulda'),
    'buat': _VerbInfo('만들다', 'Membuat', 'mandeulda'),
    'make': _VerbInfo('만들다', 'Make', 'mandeulda'),
    'memasak': _VerbInfo('요리하다', 'Memasak', 'yorihada'),
    'masak': _VerbInfo('요리하다', 'Memasak', 'yorihada'),
    'cook': _VerbInfo('요리하다', 'Cook', 'yorihada'),
    'tidur': _VerbInfo('자다', 'Tidur', 'jada'),
    'sleep': _VerbInfo('자다', 'Sleep', 'jada'),
    'bangun': _VerbInfo('일어나다', 'Bangun', 'ireonada'),
    'mandi': _VerbInfo('샤워하다', 'Mandi', 'syawohada'),
    'mencuci': _VerbInfo('씻다', 'Mencuci', 'ssitda'),
    'membersihkan': _VerbInfo('청소하다', 'Membersihkan', 'cheongsohada'),
    'bertemu': _VerbInfo('만나다', 'Bertemu', 'mannada'),
    'ketemu': _VerbInfo('만나다', 'Bertemu', 'mannada'),
    'meet': _VerbInfo('만나다', 'Meet', 'mannada'),
    'menunggu': _VerbInfo('기다리다', 'Menunggu', 'gidarida'),
    'tunggu': _VerbInfo('기다리다', 'Menunggu', 'gidarida'),
    'beristirahat': _VerbInfo('쉬다', 'Beristirahat', 'swida'),
    'istirahat': _VerbInfo('쉬다', 'Istirahat', 'swida'),
    'berolahraga': _VerbInfo('운동하다', 'Berolahraga', 'undonghada'),
    'olahraga': _VerbInfo('운동하다', 'Olahraga', 'undonghada'),
    'menyukai': _VerbInfo('좋아하다', 'Menyukai', 'joahada'),
    'suka': _VerbInfo('좋아하다', 'Suka', 'joahada'),
    'membantu': _VerbInfo('도와주다', 'Membantu', 'dowajuda'),
    'bantu': _VerbInfo('도와주다', 'Bantu', 'dowajuda'),
  };

  static final Map<String, _AdjInfo> _adjectives = {
    'cantik': _AdjInfo('예쁘다', 'Cantik', 'yeppeuda'),
    'indah': _AdjInfo('아름답다', 'Indah', 'areumdapda'),
    'bagus': _AdjInfo('좋다', 'Bagus / Baik', 'jota'),
    'baik': _AdjInfo('착하다', 'Baik hati', 'chakhada'),
    'tampan': _AdjInfo('멋있다', 'Keren / Tampan', 'meositda'),
    'keren': _AdjInfo('멋있다', 'Keren', 'meositda'),
    'pintar': _AdjInfo('똑똑하다', 'Pintar', 'ttokttokhada'),
    'ramah': _AdjInfo('친절하다', 'Ramah', 'chinjeolhada'),
    'besar': _AdjInfo('크다', 'Besar', 'keuda'),
    'kecil': _AdjInfo('작다', 'Kecil', 'jakda'),
    'banyak': _AdjInfo('많다', 'Banyak', 'manta'),
    'sedikit': _AdjInfo('적다', 'Sedikit', 'jeokda'),
    'mahal': _AdjInfo('비싸다', 'Mahal', 'bissada'),
    'murah': _AdjInfo('싸다', 'Murah', 'ssada'),
    'enak': _AdjInfo('맛있다', 'Enak / Lezat', 'masitda'),
    'lezat': _AdjInfo('맛있다', 'Lezat', 'masitda'),
    'pedas': _AdjInfo('맵다', 'Pedas', 'maepda'),
    'manis': _AdjInfo('달다', 'Manis', 'dalda'),
    'asin': _AdjInfo('짜다', 'Asin', 'jjada'),
    'panas': _AdjInfo('덥다', 'Panas (cuaca)', 'deopda'),
    'dingin': _AdjInfo('춥다', 'Dingin (cuaca)', 'chupda'),
    'hangat': _AdjInfo('따뜻하다', 'Hangat', 'ttatteuthada'),
    'sejuk': _AdjInfo('시원하다', 'Sejuk / Segar', 'siwonhada'),
    'senang': _AdjInfo('기쁘다', 'Senang', 'gippeuda'),
    'bahagia': _AdjInfo('행복하다', 'Bahagia', 'haengbokhada'),
    'sedih': _AdjInfo('슬프다', 'Sedih', 'seulpeuda'),
    'lelah': _AdjInfo('피곤하다', 'Lelah', 'pigonhada'),
    'capek': _AdjInfo('피곤하다', 'Capek', 'pigonhada'),
    'lapar': _AdjInfo('배고프다', 'Lapar', 'baegopeuda'),
    'kenyang': _AdjInfo('배부르다', 'Kenyang', 'baebureuda'),
    'bersih': _AdjInfo('깨끗하다', 'Bersih', 'kkaekkeuthada'),
    'kotor': _AdjInfo('더럽다', 'Kotor', 'deoreopda'),
    'cepat': _AdjInfo('빠르다', 'Cepat', 'ppareuda'),
    'lambat': _AdjInfo('느리다', 'Lambat', 'neurida'),
    'sibuk': _AdjInfo('바쁘다', 'Sibuk', 'bappeuda'),
    'mudah': _AdjInfo('쉽다', 'Mudah / Gampang', 'swipda'),
    'sulit': _AdjInfo('어렵다', 'Sulit / Susah', 'eoryeopda'),
  };

  static final Map<String, _PhraseInfo> _phrases = {
    'halo': _PhraseInfo('안녕하세요', 'Halo / Salam', 'annyeonghaseyo'),
    'hai': _PhraseInfo('안녕하세요', 'Hai', 'annyeonghaseyo'),
    'selamat pagi': _PhraseInfo('좋은 아침입니다', 'Selamat pagi', 'joeun achimimnida'),
    'selamat siang': _PhraseInfo('안녕하세요', 'Selamat siang', 'annyeonghaseyo'),
    'selamat malam': _PhraseInfo('안녕하세요', 'Selamat malam', 'annyeonghaseyo'),
    'selamat tidur': _PhraseInfo('안녕히 주무세요', 'Selamat tidur', 'annyeonghi jumuseyo'),
    'terima kasih': _PhraseInfo('감사합니다', 'Terima kasih', 'gamsahamnida'),
    'makasih': _PhraseInfo('고마워요', 'Makasih', 'gomawoyo'),
    'sama-sama': _PhraseInfo('천만에요', 'Sama-sama', 'cheonmaneyo'),
    'sama sama': _PhraseInfo('천만에요', 'Sama-sama', 'cheonmaneyo'),
    'maaf': _PhraseInfo('죄송합니다', 'Mohon maaf', 'joesonghamnida'),
    'minta maaf': _PhraseInfo('미안합니다', 'Minta maaf', 'mianhamnida'),
    'permisi': _PhraseInfo('실례합니다', 'Permisi', 'sillyehamnida'),
    'ya': _PhraseInfo('네', 'Ya', 'ne'),
    'tidak': _PhraseInfo('아니요', 'Tidak / Bukan', 'aniyo'),
    'apa kabar': _PhraseInfo('잘 지내세요?', 'Apa kabar?', 'jal jinaeseyo?'),
    'sampai jumpa': _PhraseInfo('또 만나요', 'Sampai jumpa lagi', 'tto mannayo'),
    'selamat tinggal': _PhraseInfo('안녕히 계세요', 'Selamat tinggal (pada yang tinggal)', 'annyeonghi gyeseyo'),
    'selamat jalan': _PhraseInfo('안녕히 가세요', 'Selamat jalan (pada yang pergi)', 'annyeonghi gaseyo'),
  };

  static final Map<String, _InstrumentInfo> _instruments = {
    'bus': _InstrumentInfo('버스', 'Bus', false),
    'bis': _InstrumentInfo('버스', 'Bus', false),
    'subway': _InstrumentInfo('지하철', 'Subway / Kereta bawah tanah', true),
    'kereta': _InstrumentInfo('기차', 'Kereta api', false),
    'taksi': _InstrumentInfo('택시', 'Taksi', false),
    'sepeda': _InstrumentInfo('자전거', 'Sepeda', false),
    'motor': _InstrumentInfo('오토바이', 'Sepeda motor', false),
    'mobil': _InstrumentInfo('자동차', 'Mobil', false),
    'pesawat': _InstrumentInfo('비행기', 'Pesawat terbang', false),
    'kapal': _InstrumentInfo('배', 'Kapal laut', false),
  };

  static final Map<String, String> _timeWords = {
    'hari ini': '오늘',
    'today': '오늘',
    'sekarang': '지금',
    'now': '지금',
    'besok': '내일',
    'tomorrow': '내일',
    'kemarin': '어제',
    'yesterday': '어제',
    'pagi': '아침에',
    'siang': '점심에',
    'malam': '밤에',
    'setiap hari': '매일',
  };

  // --------------------------------------------------------------------------
  // PARSE SENTENCE
  // --------------------------------------------------------------------------

  /// Parses any input text (short word, phrase, or complex sentence)
  /// and transforms it into structurally accurate Korean with proper particles and conjugations.
  static GrammarSentenceResult parseSentence(String input) {
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) {
      return _buildEmptyResult();
    }

    final lower = cleanInput.toLowerCase().replaceAll(RegExp(r'[?!.,]'), '');
    final words = lower.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    String detectedLang = 'id';
    if (lower.contains('the') || lower.contains(' at ') || lower.contains(' in ') ||
        lower.contains('reads') || lower.contains('drinks') || lower.contains('eats')) {
      detectedLang = 'en';
    }

    // =========================================================================
    // CASE A: SINGLE WORD OR SHORT PHRASE (Kata / Frasa Pendek)
    // =========================================================================
    if (words.length <= 2) {
      // 1. Check Phrase / Greeting
      for (final entry in _phrases.entries) {
        if (lower == entry.key || lower.startsWith(entry.key)) {
          final p = entry.value;
          final token = GrammarToken(
            role: GrammarRole.standalone,
            label: 'Ungkapan / Salam',
            originalText: cleanInput,
            koreanCore: p.korean,
            particle: null,
            fullKorean: p.korean,
            romanization: p.roman,
            explanation: 'Ungkapan salam atau frasa umum bahasa Korea yang sering digunakan sehari-hari.',
            hasBatchim: HangulSpeller.hasBatchim(p.korean),
            spellingFormula: HangulSpeller.formatFormula(p.korean),
          );
          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Ungkapan / Salam',
            informalSentence: p.korean,
            formalSentence: p.korean,
            pastSentence: p.korean,
            futureSentence: p.korean,
            baseSentence: p.korean,
            fullSpellingFormula: HangulSpeller.formatFormula(p.korean),
            grammaticalSummary: 'Frasa sapaan / ungkapan umum: "$cleanInput" diterjemahkan menjadi "${p.korean}" [${p.roman}].',
          );
        }
      }

      // 2. Check Verbs
      for (final entry in _verbs.entries) {
        if (lower == entry.key) {
          final v = entry.value;
          final inf = conjugateInformalPolite(v.base);
          final form = conjugateFormalPolite(v.base);
          final past = conjugatePastTense(v.base);
          final fut = conjugateFutureTense(v.base);

          final token = GrammarToken(
            role: GrammarRole.predicate,
            label: 'Kata Kerja (Verba)',
            originalText: cleanInput,
            koreanCore: v.base,
            particle: null,
            fullKorean: inf,
            romanization: HangulSpeller.romanizeText(inf),
            explanation: 'Akar kata verba "${v.base}" (${v.meaning}) dapat dikonjugasikan ke berbagai tingkat kesopanan dan kala waktu.',
            hasBatchim: HangulSpeller.hasBatchim(v.base.substring(0, v.base.length - 1)),
            spellingFormula: HangulSpeller.formatFormula(inf),
          );

          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Predikat (V)',
            informalSentence: inf,
            formalSentence: form,
            pastSentence: past,
            futureSentence: fut,
            baseSentence: v.base,
            fullSpellingFormula: HangulSpeller.formatFormula(inf),
            grammaticalSummary: 'Kata kerja "$cleanInput": Bentuk dasar "${v.base}" -> Informal "$inf", Formal "$form", Lampau "$past".',
          );
        }
      }

      // 3. Check Adjectives
      for (final entry in _adjectives.entries) {
        if (lower == entry.key) {
          final a = entry.value;
          final inf = conjugateInformalPolite(a.base);
          final form = conjugateFormalPolite(a.base);
          final past = conjugatePastTense(a.base);
          final fut = conjugateFutureTense(a.base);

          final token = GrammarToken(
            role: GrammarRole.predicate,
            label: 'Kata Sifat (Adjektiva)',
            originalText: cleanInput,
            koreanCore: a.base,
            particle: null,
            fullKorean: inf,
            romanization: HangulSpeller.romanizeText(inf),
            explanation: 'Kata sifat "${a.base}" (${a.meaning}) berfungsi sebagai predikat deskriptif dalam kalimat Korea.',
            hasBatchim: HangulSpeller.hasBatchim(a.base.substring(0, a.base.length - 1)),
            spellingFormula: HangulSpeller.formatFormula(inf),
          );

          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Kata Sifat (Predikat)',
            informalSentence: inf,
            formalSentence: form,
            pastSentence: past,
            futureSentence: fut,
            baseSentence: a.base,
            fullSpellingFormula: HangulSpeller.formatFormula(inf),
            grammaticalSummary: 'Kata sifat "$cleanInput": Bentuk dasar "${a.base}" -> Sopan "$inf", Formal "$form".',
          );
        }
      }

      // 4. Check Direction / Place phrase ("ke pasar", "di rumah", "pasar", "rumah")
      for (final entry in _places.entries) {
        final key = entry.key;
        if (lower == 'ke $key' || lower == 'to $key') {
          final p = entry.value;
          final full = '${p.korean}에';
          final token = GrammarToken(
            role: GrammarRole.location,
            label: 'Arah / Tujuan (K)',
            originalText: cleanInput,
            koreanCore: p.korean,
            particle: '에',
            fullKorean: full,
            romanization: HangulSpeller.romanizeText(full),
            explanation: 'Partikel penunjuk tujuan "에" dilekatkan pada tempat tujuan pergerakan.',
            hasBatchim: HangulSpeller.hasBatchim(p.korean),
            spellingFormula: HangulSpeller.formatFormula(full),
          );
          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Arah / Tujuan (K)',
            informalSentence: full,
            formalSentence: '${p.korean}(으)로',
            pastSentence: full,
            futureSentence: full,
            baseSentence: p.korean,
            fullSpellingFormula: HangulSpeller.formatFormula(full),
            grammaticalSummary: 'Frasa arah tujuan: "$cleanInput" -> "$full" [${HangulSpeller.romanizeText(full)}].',
          );
        }
        if (lower == 'di $key' || lower == 'at $key' || lower == 'in $key') {
          final p = entry.value;
          final full = '${p.korean}에서';
          final token = GrammarToken(
            role: GrammarRole.location,
            label: 'Keterangan Tempat (K)',
            originalText: cleanInput,
            koreanCore: p.korean,
            particle: '에서',
            fullKorean: full,
            romanization: HangulSpeller.romanizeText(full),
            explanation: 'Partikel lokasi "에서" menandai tempat dilakukannya kegiatan aktif.',
            hasBatchim: HangulSpeller.hasBatchim(p.korean),
            spellingFormula: HangulSpeller.formatFormula(full),
          );
          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Tempat (K)',
            informalSentence: full,
            formalSentence: full,
            pastSentence: full,
            futureSentence: full,
            baseSentence: p.korean,
            fullSpellingFormula: HangulSpeller.formatFormula(full),
            grammaticalSummary: 'Frasa tempat lokasi: "$cleanInput" -> "$full".',
          );
        }
        if (lower == key) {
          final p = entry.value;
          final hasB = HangulSpeller.hasBatchim(p.korean);
          final token = GrammarToken(
            role: GrammarRole.location,
            label: 'Tempat / Fasilitas',
            originalText: cleanInput,
            koreanCore: p.korean,
            particle: null,
            fullKorean: p.korean,
            romanization: HangulSpeller.romanizeText(p.korean),
            explanation: 'Kata benda tempat. Jika sebagai lokasi kegiatan tambahkan "에서" (${p.korean}에서), jika tujuan tambahkan "에" (${p.korean}에).',
            hasBatchim: hasB,
            spellingFormula: HangulSpeller.formatFormula(p.korean),
          );
          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Tempat (K)',
            informalSentence: hasB ? '${p.korean}이에요' : '${p.korean}예요',
            formalSentence: '${p.korean}입니다',
            pastSentence: hasB ? '${p.korean}이었어요' : '${p.korean}였어요',
            futureSentence: '${p.korean}일 거예요',
            baseSentence: p.korean,
            fullSpellingFormula: HangulSpeller.formatFormula(p.korean),
            grammaticalSummary: 'Kosakata tempat: "$cleanInput" -> "${p.korean}" [${HangulSpeller.romanizeText(p.korean)}].',
          );
        }
      }

      // 5. Check Objects / Nouns (e.g. "roti", "buku", "uang")
      for (final entry in _objects.entries) {
        if (lower == entry.key) {
          final o = entry.value;
          final hasB = HangulSpeller.hasBatchim(o.korean);
          final objParticle = hasB ? '을' : '를';
          final subjParticle = hasB ? '이' : '가';
          final topParticle = hasB ? '은' : '는';

          final token = GrammarToken(
            role: GrammarRole.object,
            label: 'Kata Benda (Nomina)',
            originalText: cleanInput,
            koreanCore: o.korean,
            particle: null,
            fullKorean: o.korean,
            romanization: HangulSpeller.romanizeText(o.korean),
            explanation: 'Kata benda: ${o.korean}. Partikel objek: "${o.korean}$objParticle", partikel subjek: "${o.korean}$subjParticle", partikel topik: "${o.korean}$topParticle".',
            hasBatchim: hasB,
            spellingFormula: HangulSpeller.formatFormula(o.korean),
          );

          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Kata Benda (N)',
            informalSentence: hasB ? '${o.korean}이에요' : '${o.korean}예요',
            formalSentence: '${o.korean}입니다',
            pastSentence: hasB ? '${o.korean}이었어요' : '${o.korean}였어요',
            futureSentence: '${o.korean}일 거예요',
            baseSentence: o.korean,
            fullSpellingFormula: HangulSpeller.formatFormula(o.korean),
            grammaticalSummary: 'Kosakata benda: "$cleanInput" -> "${o.korean}" [${HangulSpeller.romanizeText(o.korean)}]. Partikel objek: ${o.korean}$objParticle.',
          );
        }
      }

      // 6. Check Subjects / Pronouns (e.g. "saya", "kamu", "budi")
      for (final entry in _subjects.entries) {
        if (lower == entry.key) {
          final s = entry.value;
          final hasB = HangulSpeller.hasBatchim(s.korean);
          final topParticle = hasB ? '은' : '는';
          final full = '${s.korean}$topParticle';

          final token = GrammarToken(
            role: GrammarRole.subject,
            label: 'Subjek / Kata Ganti',
            originalText: cleanInput,
            koreanCore: s.korean,
            particle: topParticle,
            fullKorean: full,
            romanization: HangulSpeller.romanizeText(full),
            explanation: 'Kata ganti / subjek: ${s.korean}. Dengan partikel topik menjadi "$full".',
            hasBatchim: hasB,
            spellingFormula: HangulSpeller.formatFormula(full),
          );

          return GrammarSentenceResult(
            originalInput: cleanInput,
            detectedLanguage: detectedLang,
            tokens: [token],
            sovPattern: 'Subjek (S)',
            informalSentence: full,
            formalSentence: full,
            pastSentence: full,
            futureSentence: full,
            baseSentence: s.korean,
            fullSpellingFormula: HangulSpeller.formatFormula(full),
            grammaticalSummary: 'Subjek / Kata ganti: "$cleanInput" -> "$full" [${HangulSpeller.romanizeText(full)}].',
          );
        }
      }
    }

    // =========================================================================
    // CASE B: SENTENCES (KALIMAT PENDEK S.D. PANJANG)
    // =========================================================================

    // 1. Detect Time Adverb
    String? foundTimeKorean;
    String? foundTimeOriginal;
    for (final entry in _timeWords.entries) {
      final reg = RegExp(r'\b' + RegExp.escape(entry.key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundTimeKorean = entry.value;
        foundTimeOriginal = entry.key;
        break;
      }
    }

    // 2. Detect Subject (ONLY if explicitly mentioned)
    _SubjectInfo? foundSubject;
    String? subjectOriginal;
    for (final entry in _subjects.entries) {
      final key = entry.key;
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundSubject = entry.value;
        subjectOriginal = key[0].toUpperCase() + key.substring(1);
        break;
      }
    }

    // 3. Detect Place / Location
    _PlaceInfo? foundPlace;
    String? placeOriginal;
    for (final entry in _places.entries) {
      final key = entry.key;
      if (key == 'korea' && (lower.contains('bahasa korea') || lower.contains('korean'))) {
        if (!lower.contains('di korea') && !lower.contains('in korea') && !lower.contains('ke korea')) {
          continue;
        }
      }
      if (key == 'indonesia' && (lower.contains('bahasa indonesia') || lower.contains('indonesian'))) {
        if (!lower.contains('di indonesia') && !lower.contains('in indonesia') && !lower.contains('ke indonesia')) {
          continue;
        }
      }
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundPlace = entry.value;
        placeOriginal = key;
        break;
      }
    }

    // 4. Detect Instrument / Means (Transportation)
    _InstrumentInfo? foundInstrument;
    String? instrumentOriginal;
    for (final entry in _instruments.entries) {
      final key = entry.key;
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundInstrument = entry.value;
        instrumentOriginal = key;
        break;
      }
    }

    // 5. Detect Object(s)
    _ObjectInfo? foundObject;
    String? objectOriginal;
    for (final entry in _objects.entries) {
      final key = entry.key;
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundObject = entry.value;
        objectOriginal = key;
        break;
      }
    }

    // 6. Detect Verb Predicate
    _VerbInfo? foundVerb;
    String? verbOriginal;
    for (final entry in _verbs.entries) {
      final key = entry.key;
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundVerb = entry.value;
        verbOriginal = key;
        break;
      }
    }

    // 7. Detect Adjective Predicate (if no verb found)
    _AdjInfo? foundAdj;
    if (foundVerb == null) {
      for (final entry in _adjectives.entries) {
        final key = entry.key;
        final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
        if (reg.hasMatch(lower)) {
          foundAdj = entry.value;
          break;
        }
      }
    }

    // If still no verb and no adjective, but a place/object was given with a subject:
    // e.g. "Saya seorang guru", "Ini adalah buku"
    // Keep it natural without forcing "makan"
    final isMovementVerb = foundVerb != null && (foundVerb.base == '가다' || foundVerb.base == '오다');

    // ------------------------------------------------------------------------
    // BUILD GRAMMAR TOKENS LIST
    // ------------------------------------------------------------------------
    final tokens = <GrammarToken>[];

    // (A) Time Token
    if (foundTimeKorean != null) {
      tokens.add(GrammarToken(
        role: GrammarRole.time,
        label: 'Keterangan Waktu',
        originalText: foundTimeOriginal ?? 'Waktu',
        koreanCore: foundTimeKorean,
        particle: null,
        fullKorean: foundTimeKorean,
        romanization: HangulSpeller.romanizeText(foundTimeKorean),
        explanation: 'Keterangan waktu biasanya diletakkan di awal kalimat.',
        hasBatchim: HangulSpeller.hasBatchim(foundTimeKorean),
        spellingFormula: HangulSpeller.formatFormula(foundTimeKorean),
      ));
    }

    // (B) Subject Token (Include ONLY if present in input)
    if (foundSubject != null) {
      final subjHasBatchim = HangulSpeller.hasBatchim(foundSubject.korean);
      final subjParticle = subjHasBatchim ? '은' : '는';
      final fullSubj = '${foundSubject.korean}$subjParticle';
      tokens.add(GrammarToken(
        role: GrammarRole.subject,
        label: 'Subjek (주어)',
        originalText: subjectOriginal ?? 'Subjek',
        koreanCore: foundSubject.korean,
        particle: subjParticle,
        fullKorean: fullSubj,
        romanization: HangulSpeller.romanizeText(fullSubj),
        explanation: subjHasBatchim
            ? 'Menggunakan partikel topik "은" karena berakhiran konsonan (Batchim).'
            : 'Menggunakan partikel topik "는" karena berakhiran vokal (tanpa Batchim).',
        hasBatchim: subjHasBatchim,
        spellingFormula: HangulSpeller.formatFormula(fullSubj),
      ));
    }

    // (C) Instrument / Means Token (if present)
    if (foundInstrument != null) {
      final instHasRieul = HangulSpeller.endsWithRieulBatchim(foundInstrument.korean);
      final instHasBatchim = HangulSpeller.hasBatchim(foundInstrument.korean);
      final instParticle = (instHasRieul || !instHasBatchim) ? '로' : '으로';
      final fullInst = '${foundInstrument.korean}$instParticle';

      tokens.add(GrammarToken(
        role: GrammarRole.instrument,
        label: 'Alat (수단)',
        originalText: instrumentOriginal ?? 'Sarana',
        koreanCore: foundInstrument.korean,
        particle: instParticle,
        fullKorean: fullInst,
        romanization: HangulSpeller.romanizeText(fullInst),
        explanation: 'Partikel "(으)로" menandai alat atau sarana transportasi yang dipakai.',
        hasBatchim: instHasBatchim,
        spellingFormula: HangulSpeller.formatFormula(fullInst),
      ));
    }

    // (D) Location Token (if present)
    if (foundPlace != null) {
      final isDestination = isMovementVerb || lower.contains('ke $placeOriginal') || lower.contains('to $placeOriginal');
      final placeParticle = isDestination ? '에' : '에서';
      final placeReason = isDestination
          ? 'Partikel tujuan "에" dipakai bersama kata kerja pergerakan / arah.'
          : 'Partikel "에서" menandai tempat dilakukannya aktivitas aktif.';
      final fullPlace = '${foundPlace.korean}$placeParticle';

      tokens.add(GrammarToken(
        role: GrammarRole.location,
        label: isDestination ? 'Tujuan (방향)' : 'Tempat (장소)',
        originalText: placeOriginal != null ? 'di/ke $placeOriginal' : 'di lokasi',
        koreanCore: foundPlace.korean,
        particle: placeParticle,
        fullKorean: fullPlace,
        romanization: HangulSpeller.romanizeText(fullPlace),
        explanation: placeReason,
        hasBatchim: HangulSpeller.hasBatchim(foundPlace.korean),
        spellingFormula: HangulSpeller.formatFormula(fullPlace),
      ));
    }

    // (E) Object Token (if present)
    if (foundObject != null) {
      final objHasBatchim = HangulSpeller.hasBatchim(foundObject.korean);
      final objParticle = objHasBatchim ? '을' : '를';
      final fullObj = '${foundObject.korean}$objParticle';
      tokens.add(GrammarToken(
        role: GrammarRole.object,
        label: 'Objek (목적어)',
        originalText: objectOriginal ?? 'Objek',
        koreanCore: foundObject.korean,
        particle: objParticle,
        fullKorean: fullObj,
        romanization: HangulSpeller.romanizeText(fullObj),
        explanation: objHasBatchim
            ? 'Menggunakan partikel objek "을" karena kata berakhiran konsonan (Batchim).'
            : 'Menggunakan partikel objek "를" karena kata berakhiran vokal.',
        hasBatchim: objHasBatchim,
        spellingFormula: HangulSpeller.formatFormula(fullObj),
      ));
    }

    // (F) Predicate Token (Verb or Adjective)
    String informalPred;
    String formalPred;
    String pastPred;
    String futurePred;
    String basePred;

    if (foundVerb != null) {
      informalPred = conjugateInformalPolite(foundVerb.base);
      formalPred = conjugateFormalPolite(foundVerb.base);
      pastPred = conjugatePastTense(foundVerb.base);
      futurePred = conjugateFutureTense(foundVerb.base);
      basePred = foundVerb.base;

      tokens.add(GrammarToken(
        role: GrammarRole.predicate,
        label: 'Predikat (서술어)',
        originalText: verbOriginal ?? 'Predikat',
        koreanCore: foundVerb.base,
        particle: null,
        fullKorean: informalPred,
        romanization: HangulSpeller.romanizeText(informalPred),
        explanation: 'Akar kata verba "${foundVerb.base}" dikonjugasikan di posisi akhir kalimat (pola SOV).',
        hasBatchim: HangulSpeller.hasBatchim(foundVerb.base.substring(0, foundVerb.base.length - 1)),
        spellingFormula: HangulSpeller.formatFormula(informalPred),
      ));
    } else if (foundAdj != null) {
      informalPred = conjugateInformalPolite(foundAdj.base);
      formalPred = conjugateFormalPolite(foundAdj.base);
      pastPred = conjugatePastTense(foundAdj.base);
      futurePred = conjugateFutureTense(foundAdj.base);
      basePred = foundAdj.base;

      tokens.add(GrammarToken(
        role: GrammarRole.predicate,
        label: 'Predikat Adjektiva',
        originalText: cleanInput,
        koreanCore: foundAdj.base,
        particle: null,
        fullKorean: informalPred,
        romanization: HangulSpeller.romanizeText(informalPred),
        explanation: 'Kata sifat "${foundAdj.base}" bertindak sebagai predikat deskriptif.',
        hasBatchim: HangulSpeller.hasBatchim(foundAdj.base.substring(0, foundAdj.base.length - 1)),
        spellingFormula: HangulSpeller.formatFormula(informalPred),
      ));
    } else {
      // Fallback: If sentence has object/noun but no verb, apply polite copula
      // e.g. "Saya Budi" -> 저는 부디예요 / 부디입니다
      if (tokens.isNotEmpty) {
        final lastToken = tokens.last;
        final hasB = lastToken.hasBatchim;
        informalPred = hasB ? '이에요' : '예요';
        formalPred = '입니다';
        pastPred = hasB ? '이었어요' : '였어요';
        futurePred = '일 거예요';
        basePred = '이다';
      } else {
        // If nothing recognized at all, provide transliterated phonetic token
        final phonHangul = _transliteratePhonetic(cleanInput);
        final hasB = HangulSpeller.hasBatchim(phonHangul);
        tokens.add(GrammarToken(
          role: GrammarRole.standalone,
          label: 'Teks Bebas / Transliterasi',
          originalText: cleanInput,
          koreanCore: phonHangul,
          particle: null,
          fullKorean: phonHangul,
          romanization: HangulSpeller.romanizeText(phonHangul),
          explanation: 'Transliterasi fonetik kata bebas ke dalam aksara Hangul Korea.',
          hasBatchim: hasB,
          spellingFormula: HangulSpeller.formatFormula(phonHangul),
        ));
        informalPred = phonHangul;
        formalPred = phonHangul;
        pastPred = phonHangul;
        futurePred = phonHangul;
        basePred = phonHangul;
      }
    }

    // ------------------------------------------------------------------------
    // CONSTRUCT FULL SENTENCES
    // ------------------------------------------------------------------------
    final nonPredTokens = tokens.where((t) => t.role != GrammarRole.predicate).map((t) => t.fullKorean).toList();

    String informalSentence;
    String formalSentence;
    String pastSentence;
    String futureSentence;
    String baseSentence;

    if (foundVerb != null || foundAdj != null) {
      informalSentence = [...nonPredTokens, informalPred].join(' ');
      formalSentence = [...nonPredTokens, formalPred].join(' ');
      pastSentence = [...nonPredTokens, pastPred].join(' ');
      futureSentence = [...nonPredTokens, futurePred].join(' ');
      baseSentence = [...nonPredTokens, basePred].join(' ');
    } else {
      informalSentence = nonPredTokens.join(' ');
      formalSentence = nonPredTokens.join(' ');
      pastSentence = nonPredTokens.join(' ');
      futureSentence = nonPredTokens.join(' ');
      baseSentence = nonPredTokens.join(' ');
    }

    // SOV Pattern String
    final patternParts = <String>[];
    for (final t in tokens) {
      switch (t.role) {
        case GrammarRole.time:
          patternParts.add('Waktu');
          break;
        case GrammarRole.subject:
          patternParts.add('Subjek (S)');
          break;
        case GrammarRole.instrument:
          patternParts.add('Sarana');
          break;
        case GrammarRole.location:
          patternParts.add('Keterangan (K)');
          break;
        case GrammarRole.object:
          patternParts.add('Objek (O)');
          break;
        case GrammarRole.predicate:
          patternParts.add('Predikat (V)');
          break;
        case GrammarRole.standalone:
          patternParts.add('Kosakata');
          break;
      }
    }
    final sovPattern = patternParts.isNotEmpty ? patternParts.join(' ➔ ') : 'S ➔ O ➔ V';
    final fullSpellingFormula = HangulSpeller.formatFormula(informalSentence);
    final summary = 'Kalimat disesuaikan dengan pola tata bahasa Korea (S-O-V), predikat di akhir kalimat, dan partikel disesuaikan secara otomatis menurut konsonan akhir (Batchim).';

    return GrammarSentenceResult(
      originalInput: cleanInput,
      detectedLanguage: detectedLang,
      tokens: tokens,
      sovPattern: sovPattern,
      informalSentence: informalSentence,
      formalSentence: formalSentence,
      pastSentence: pastSentence,
      futureSentence: futureSentence,
      baseSentence: baseSentence,
      fullSpellingFormula: fullSpellingFormula,
      grammaticalSummary: summary,
    );
  }

  /// Phonetic syllable transliterator for Latin text into Hangul
  static String _transliteratePhonetic(String text) {
    if (text.isEmpty) return text;
    final clean = text.trim();
    // Common loanwords/names mapping
    final lower = clean.toLowerCase();
    if (lower == 'andi') return '안디';
    if (lower == 'budi') return '부디';
    if (lower == 'siti') return '시티';
    if (lower == 'rudi') return '루디';
    if (lower == 'jakarta') return '자카르타';
    if (lower == 'bandung') return '반둥';
    if (lower == 'surabaya') return '수라바야';
    if (lower == 'bali') return '발리';
    if (lower == 'indonesia') return '인도네시아';
    if (lower == 'pizza') return '피자';
    if (lower == 'burger') return '버거';

    return clean;
  }

  static GrammarSentenceResult _buildEmptyResult() {
    return const GrammarSentenceResult(
      originalInput: '',
      detectedLanguage: 'id',
      tokens: [],
      sovPattern: 'S ➔ O ➔ V',
      informalSentence: '',
      formalSentence: '',
      pastSentence: '',
      futureSentence: '',
      baseSentence: '',
      fullSpellingFormula: '',
      grammaticalSummary: 'Ketik kata atau kalimat apapun dalam bahasa Indonesia untuk membedah struktur SOV.',
    );
  }
}

// ----------------------------------------------------------------------------
// Internal Helper Types
// ----------------------------------------------------------------------------
class _SubjectInfo {
  final String korean;
  final String meaning;
  final bool defaultBatchim;
  _SubjectInfo(this.korean, this.meaning, this.defaultBatchim);
}

class _PlaceInfo {
  final String korean;
  final String meaning;
  final bool defaultBatchim;
  _PlaceInfo(this.korean, this.meaning, this.defaultBatchim);
}

class _ObjectInfo {
  final String korean;
  final String meaning;
  final bool defaultBatchim;
  _ObjectInfo(this.korean, this.meaning, this.defaultBatchim);
}

class _VerbInfo {
  final String base;
  final String meaning;
  final String roman;
  _VerbInfo(this.base, this.meaning, this.roman);
}

class _AdjInfo {
  final String base;
  final String meaning;
  final String roman;
  _AdjInfo(this.base, this.meaning, this.roman);
}

class _PhraseInfo {
  final String korean;
  final String meaning;
  final String roman;
  _PhraseInfo(this.korean, this.meaning, this.roman);
}

class _InstrumentInfo {
  final String korean;
  final String meaning;
  final bool defaultBatchim;
  _InstrumentInfo(this.korean, this.meaning, this.defaultBatchim);
}
