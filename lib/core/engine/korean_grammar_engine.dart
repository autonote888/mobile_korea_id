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
  location,   // 처소/장소 (Place / Where)
  instrument, // 수단/도구 (By / With / Instrument)
  object,     // 목적어 (O)
  predicate,  // 서술어 (V / Predicate)
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
  final String sovPattern; // e.g. "S - L - O - V"
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
    // 보다 -> 봐요, 오다 -> 와요
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
    if (stem == '마시') return '마셔요';
    if (stem == '가르치') return '가르쳐요';
    if (stem == '기다리') return '기다려요';
    if (stem == '배우') return '배워요';
    if (stem == '주') return '줘요';
    if (stem == '쉬') return '쉬어요';

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
      // No batchim, inspect vowel for combination
      // Vowel ㅏ (index 0) + 아 -> ㅏ (already handled by common verbs)
      // Vowel ㅗ (index 8) + 아 -> ㅘ
      // Vowel ㅜ (index 13) + 어 -> ㅝ
      // Vowel ㅣ (index 20) + 어 -> ㅕ
      // Vowel ㅡ (index 18) -> drops and looks at previous or becomes ㅓ
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
        // Replace batchim ㄹ with ㅂ
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
      // Attach ㅂ into the last syllable as batchim
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
  // DETERMINISTIC SOV SENTENCE MAPPING & PARSING
  // --------------------------------------------------------------------------

  /// Predefined dictionary of grammatical elements for deterministic parsing.
  static final Map<String, _SubjectInfo> _subjects = {
    'saya': _SubjectInfo('저', 'I (polite)', false),
    'aku': _SubjectInfo('나', 'I (informal)', false),
    'i': _SubjectInfo('저', 'I', false),
    'me': _SubjectInfo('저', 'Me', false),
    'kamu': _SubjectInfo('너', 'You (informal)', false),
    'anda': _SubjectInfo('당신', 'You (polite)', true),
    'you': _SubjectInfo('당신', 'You', true),
    'kami': _SubjectInfo('우리', 'We', false),
    'kita': _SubjectInfo('우리', 'We', false),
    'we': _SubjectInfo('우리', 'We', false),
    'budi': _SubjectInfo('부디', 'Budi', false),
    'minho': _SubjectInfo('민호', 'Minho', false),
    'guru': _SubjectInfo('선생님', 'Teacher', true),
    'teacher': _SubjectInfo('선생님', 'Teacher', true),
    'siswa': _SubjectInfo('학생', 'Student', true),
    'murid': _SubjectInfo('학생', 'Student', true),
    'student': _SubjectInfo('학생', 'Student', true),
    'teman': _SubjectInfo('친구', 'Friend', false),
    'friend': _SubjectInfo('친구', 'Friend', false),
    'ibu': _SubjectInfo('어머니', 'Mother', false),
    'mother': _SubjectInfo('어머니', 'Mother', false),
    'ayah': _SubjectInfo('아버지', 'Father', false),
    'father': _SubjectInfo('아버지', 'Father', false),
    'adik': _SubjectInfo('동생', 'Younger sibling', true),
    'kakak': _SubjectInfo('형', 'Older brother', true),
  };

  static final Map<String, _PlaceInfo> _places = {
    'rumah': _PlaceInfo('집', 'Home / House', true),
    'home': _PlaceInfo('집', 'Home', true),
    'house': _PlaceInfo('집', 'House', true),
    'sekolah': _PlaceInfo('학교', 'School', false),
    'school': _PlaceInfo('학교', 'School', false),
    'perpustakaan': _PlaceInfo('도서관', 'Library', true),
    'library': _PlaceInfo('도서관', 'Library', true),
    'restoran': _PlaceInfo('식당', 'Restaurant', true),
    'restaurant': _PlaceInfo('식당', 'Restaurant', true),
    'kantor': _PlaceInfo('사무실', 'Office', true),
    'office': _PlaceInfo('사무실', 'Office', true),
    'pasar': _PlaceInfo('시장', 'Market', true),
    'market': _PlaceInfo('시장', 'Market', true),
    'taman': _PlaceInfo('공원', 'Park', true),
    'park': _PlaceInfo('공원', 'Park', true),
    'kafe': _PlaceInfo('카페', 'Cafe', false),
    'cafe': _PlaceInfo('카페', 'Cafe', false),
    'korea': _PlaceInfo('한국', 'Korea', true),
    'indonesia': _PlaceInfo('인도네시아', 'Indonesia', false),
  };

  static final Map<String, _ObjectInfo> _objects = {
    'nasi': _ObjectInfo('밥', 'Rice', true),
    'makanan': _ObjectInfo('밥', 'Food', true),
    'rice': _ObjectInfo('밥', 'Rice', true),
    'meal': _ObjectInfo('밥', 'Meal', true),
    'air': _ObjectInfo('물', 'Water', true),
    'water': _ObjectInfo('물', 'Water', true),
    'buku': _ObjectInfo('책', 'Book', true),
    'book': _ObjectInfo('책', 'Book', true),
    'apel': _ObjectInfo('사과', 'Apple', false),
    'apple': _ObjectInfo('사과', 'Apple', false),
    'roti': _ObjectInfo('빵', 'Bread', true),
    'bread': _ObjectInfo('빵', 'Bread', true),
    'susu': _ObjectInfo('우유', 'Milk', false),
    'milk': _ObjectInfo('우유', 'Milk', false),
    'kopi': _ObjectInfo('커피', 'Coffee', false),
    'coffee': _ObjectInfo('커피', 'Coffee', false),
    'teh': _ObjectInfo('차', 'Tea', false),
    'tea': _ObjectInfo('차', 'Tea', false),
    'film': _ObjectInfo('영화', 'Movie', false),
    'movie': _ObjectInfo('영화', 'Movie', false),
    'musik': _ObjectInfo('음악', 'Music', true),
    'music': _ObjectInfo('음악', 'Music', true),
    'bahasa korea': _ObjectInfo('한국어', 'Korean language', false),
    'korean': _ObjectInfo('한국어', 'Korean language', false),
    'bahasa indonesia': _ObjectInfo('인도네시아어', 'Indonesian language', false),
    'baju': _ObjectInfo('옷', 'Clothes', true),
    'surat': _ObjectInfo('편지', 'Letter', false),
    'letter': _ObjectInfo('편지', 'Letter', false),
    'uang': _ObjectInfo('돈', 'Money', true),
    'money': _ObjectInfo('돈', 'Money', true),
    'ponsel': _ObjectInfo('핸드폰', 'Phone', true),
    'hp': _ObjectInfo('핸드폰', 'Phone', true),
  };

  static final Map<String, _VerbInfo> _verbs = {
    'makan': _VerbInfo('먹다', 'Eat', 'meokda'),
    'eat': _VerbInfo('먹다', 'Eat', 'meokda'),
    'eats': _VerbInfo('먹다', 'Eat', 'meokda'),
    'minum': _VerbInfo('마시다', 'Drink', 'masida'),
    'drink': _VerbInfo('마시다', 'Drink', 'masida'),
    'drinks': _VerbInfo('마시다', 'Drink', 'masida'),
    'membaca': _VerbInfo('읽다', 'Read', 'ikda'),
    'baca': _VerbInfo('읽다', 'Read', 'ikda'),
    'read': _VerbInfo('읽다', 'Read', 'ikda'),
    'reads': _VerbInfo('읽다', 'Read', 'ikda'),
    'menulis': _VerbInfo('쓰다', 'Write', 'sseuda'),
    'tulis': _VerbInfo('쓰다', 'Write', 'sseuda'),
    'write': _VerbInfo('쓰다', 'Write', 'sseuda'),
    'melihat': _VerbInfo('보다', 'Watch / See', 'boda'),
    'menonton': _VerbInfo('보다', 'Watch', 'boda'),
    'watch': _VerbInfo('보다', 'Watch', 'boda'),
    'see': _VerbInfo('보다', 'See', 'boda'),
    'pergi': _VerbInfo('가다', 'Go', 'gada'),
    'go': _VerbInfo('가다', 'Go', 'gada'),
    'goes': _VerbInfo('가다', 'Go', 'gada'),
    'datang': _VerbInfo('오다', 'Come', 'oda'),
    'come': _VerbInfo('오다', 'Come', 'oda'),
    'belajar': _VerbInfo('공부하다', 'Study', 'gongbuhada'),
    'study': _VerbInfo('공부하다', 'Study', 'gongbuhada'),
    'bekerja': _VerbInfo('일하다', 'Work', 'ilhada'),
    'kerja': _VerbInfo('일하다', 'Work', 'ilhada'),
    'work': _VerbInfo('일하다', 'Work', 'ilhada'),
    'membeli': _VerbInfo('사다', 'Buy', 'sada'),
    'beli': _VerbInfo('사다', 'Buy', 'sada'),
    'buy': _VerbInfo('사다', 'Buy', 'sada'),
    'membuat': _VerbInfo('만들다', 'Make', 'mandeulda'),
    'make': _VerbInfo('만들다', 'Make', 'mandeulda'),
    'mendengarkan': _VerbInfo('듣다', 'Listen', 'deutda'),
    'listen': _VerbInfo('듣다', 'Listen', 'deutda'),
    'bertemu': _VerbInfo('만나다', 'Meet', 'mannada'),
    'meet': _VerbInfo('만나다', 'Meet', 'mannada'),
    'tidur': _VerbInfo('자다', 'Sleep', 'jada'),
    'sleep': _VerbInfo('자다', 'Sleep', 'jada'),
  };

  /// Parses an input text (Indonesian or English) and transforms it into
  /// a structurally sound Korean SOV sentence with smart particle injection.
  static GrammarSentenceResult parseSentence(String input) {
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) {
      return _buildEmptyResult();
    }

    final lower = cleanInput.toLowerCase();
    String detectedLang = 'id';
    if (lower.contains('the') || lower.contains(' at ') || lower.contains(' in ') || lower.contains('reads') || lower.contains('drinks') || lower.contains('eats')) {
      detectedLang = 'en';
    }

    // 1. Detect Subject
    _SubjectInfo? foundSubject;
    String subjectText = 'Saya';
    for (final entry in _subjects.entries) {
      final key = entry.key;
      // Match as word
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundSubject = entry.value;
        subjectText = key[0].toUpperCase() + key.substring(1);
        break;
      }
    }
    // Default subject if not specified
    foundSubject ??= _SubjectInfo('저', 'I (polite)', false);

    // 2. Detect Place / Location
    _PlaceInfo? foundPlace;
    String? placeOriginal;
    for (final entry in _places.entries) {
      final key = entry.key;
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundPlace = entry.value;
        placeOriginal = key;
        break;
      }
    }

    // 3. Detect Verb / Predicate
    _VerbInfo? foundVerb;
    String verbText = 'makan';
    for (final entry in _verbs.entries) {
      final key = entry.key;
      final reg = RegExp(r'\b' + RegExp.escape(key) + r'\b');
      if (reg.hasMatch(lower)) {
        foundVerb = entry.value;
        verbText = key;
        break;
      }
    }
    foundVerb ??= _VerbInfo('먹다', 'Eat', 'meokda');

    // 4. Detect Object
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
    // If movement verb (가다 / 오다) and place is detected without an explicit object,
    // the place functions as destination (학교에 가요).
    final isMovementVerb = foundVerb.base == '가다' || foundVerb.base == '오다';

    // ------------------------------------------------------------------------
    // BUILD GRAMMAR TOKENS
    // ------------------------------------------------------------------------
    final tokens = <GrammarToken>[];

    // Subject Token (Topik: 은 / 는)
    final subjHasBatchim = HangulSpeller.hasBatchim(foundSubject.korean);
    final subjParticle = subjHasBatchim ? '은' : '는';
    final fullSubj = '${foundSubject.korean}$subjParticle';
    tokens.add(GrammarToken(
      role: GrammarRole.subject,
      label: 'Subjek (주어)',
      originalText: subjectText,
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

    // Location Token (if present)
    if (foundPlace != null) {
      final placeParticle = isMovementVerb ? '에' : '에서';
      final placeReason = isMovementVerb
          ? 'Partikel tujuan "에" dipakai bersama kata kerja pergerakan (${foundVerb.base}).'
          : 'Partikel "에서" menandai tempat dilakukannya kegiatan aktif.';
      final fullPlace = '${foundPlace.korean}$placeParticle';
      tokens.add(GrammarToken(
        role: GrammarRole.location,
        label: isMovementVerb ? 'Tujuan (방향/도착)' : 'Keterangan Tempat (장소)',
        originalText: placeOriginal != null ? 'di $placeOriginal' : 'di lokasi',
        koreanCore: foundPlace.korean,
        particle: placeParticle,
        fullKorean: fullPlace,
        romanization: HangulSpeller.romanizeText(fullPlace),
        explanation: placeReason,
        hasBatchim: HangulSpeller.hasBatchim(foundPlace.korean),
        spellingFormula: HangulSpeller.formatFormula(fullPlace),
      ));
    }

    // Object Token (if present and not redundant)
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

    // Predicate Token (Conjugated)
    final informalVerb = conjugateInformalPolite(foundVerb.base);
    final formalVerb = conjugateFormalPolite(foundVerb.base);
    final pastVerb = conjugatePastTense(foundVerb.base);
    final futureVerb = conjugateFutureTense(foundVerb.base);

    tokens.add(GrammarToken(
      role: GrammarRole.predicate,
      label: 'Predikat (서술어)',
      originalText: verbText,
      koreanCore: foundVerb.base,
      particle: null,
      fullKorean: informalVerb,
      romanization: HangulSpeller.romanizeText(informalVerb),
      explanation: 'Akar kata "${foundVerb.base}" dikonjugasikan ke tingkat kesopanan informal (-아요/어요/해요) dan formal (-ㅂ니다/습니다).',
      hasBatchim: HangulSpeller.hasBatchim(foundVerb.base.substring(0, foundVerb.base.length - 1)),
      spellingFormula: HangulSpeller.formatFormula(informalVerb),
    ));

    // Construct full sentences
    final corePartsInformal = <String>[];
    final corePartsFormal = <String>[];
    final corePartsPast = <String>[];
    final corePartsFuture = <String>[];
    final corePartsBase = <String>[];

    for (final token in tokens) {
      if (token.role != GrammarRole.predicate) {
        corePartsInformal.add(token.fullKorean);
        corePartsFormal.add(token.fullKorean);
        corePartsPast.add(token.fullKorean);
        corePartsFuture.add(token.fullKorean);
        corePartsBase.add(token.fullKorean);
      } else {
        corePartsInformal.add(informalVerb);
        corePartsFormal.add(formalVerb);
        corePartsPast.add(pastVerb);
        corePartsFuture.add(futureVerb);
        corePartsBase.add(foundVerb.base);
      }
    }

    final informalSentence = corePartsInformal.join(' ');
    final formalSentence = corePartsFormal.join(' ');
    final pastSentence = corePartsPast.join(' ');
    final futureSentence = corePartsFuture.join(' ');
    final baseSentence = corePartsBase.join(' ');

    // SOV Pattern String
    final patternParts = <String>[];
    for (final t in tokens) {
      switch (t.role) {
        case GrammarRole.subject:
          patternParts.add('Subjek (S)');
          break;
        case GrammarRole.location:
          patternParts.add('Keterangan (K)');
          break;
        case GrammarRole.instrument:
          patternParts.add('Sarana');
          break;
        case GrammarRole.object:
          patternParts.add('Objek (O)');
          break;
        case GrammarRole.predicate:
          patternParts.add('Predikat (V)');
          break;
      }
    }
    final sovPattern = patternParts.join(' ➔ ');

    final fullSpellingFormula = HangulSpeller.formatFormula(informalSentence);
    final summary = 'Transformasi pola S-V-O ke S-O-V Korea: Predikat (${foundVerb.base}) diletakkan di akhir kalimat dengan injeksi partikel otomatis sesuai deteksi konsonan akhir (Batchim).';

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
      grammaticalSummary: 'Ketik kalimat dalam bahasa Indonesia atau Inggris untuk membedah struktur SOV.',
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
