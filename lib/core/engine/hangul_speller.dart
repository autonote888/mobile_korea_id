/// Unicode Mathematical Deconstructor for Hangul Syllables.
///
/// Implements the standard Hangul Syllable Decomposition algorithm (Unicode Standard 3.0+),
/// operating over code points U+AC00 through U+D7A3 with zero runtime memory bloat.
class HangulSpeller {
  HangulSpeller._();

  static const int hangulBase = 0xAC00;
  static const int hangulEnd = 0xD7A3;

  static const int choseongBase = 0x1100;
  static const int jungseongBase = 0x1161;
  static const int jongseongBase = 0x11A7;

  static const int jungseongCount = 21;
  static const int jongseongCount = 28;
  static const int syllableCount = jungseongCount * jongseongCount; // 588

  /// 19 Initial Consonants (초성 - Choseong)
  static const List<String> choseongList = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];

  /// 21 Medial Vowels (중성 - Jungseong)
  static const List<String> jungseongList = [
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
    'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'
  ];

  /// 28 Final Consonants (종성 / 받침 - Jongseong / Batchim)
  /// Index 0 represents no batchim (empty string).
  static const List<String> jongseongList = [
    '', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ',
    'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];

  /// Choseong Romanization Table
  static const List<String> choseongRoman = [
    'g', 'kk', 'n', 'd', 'tt', 'r', 'm', 'b', 'pp', 's',
    'ss', '', 'j', 'jj', 'ch', 'k', 't', 'p', 'h'
  ];

  /// Jungseong Romanization Table
  static const List<String> jungseongRoman = [
    'a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa',
    'wae', 'oe', 'yo', 'u', 'wo', 'we', 'wi', 'yu', 'eu', 'ui', 'i'
  ];

  /// Jongseong Romanization Table
  static const List<String> jongseongRoman = [
    '', 'k', 'k', 'k', 'n', 'n', 'n', 't', 'l', 'k',
    'm', 'p', 'l', 't', 'p', 'l', 'm', 'p', 'p', 't',
    't', 'ng', 't', 't', 'k', 't', 'p', 't'
  ];

  /// Checks if the given character code is within the Hangul Syllables block.
  static bool isHangulSyllableCode(int code) {
    return code >= hangulBase && code <= hangulEnd;
  }

  /// Checks if a character string is a Hangul Syllable.
  static bool isHangulSyllable(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return isHangulSyllableCode(code);
  }

  /// Deconstructs a single Hangul syllable character into its constituent parts.
  /// Returns null if [syllable] is not a valid precomposed Hangul syllable.
  static HangulDecomposition? decomposeChar(String syllable) {
    if (syllable.isEmpty) return null;
    final code = syllable.codeUnitAt(0);
    if (!isHangulSyllableCode(code)) return null;

    final sIndex = code - hangulBase;
    final lIndex = sIndex ~/ syllableCount;
    final vIndex = (sIndex % syllableCount) ~/ jongseongCount;
    final tIndex = sIndex % jongseongCount;

    final choseong = choseongList[lIndex];
    final jungseong = jungseongList[vIndex];
    final jongseong = jongseongList[tIndex];

    return HangulDecomposition(
      syllable: syllable,
      choseong: choseong,
      jungseong: jungseong,
      jongseong: jongseong,
      hasBatchim: tIndex > 0,
      choseongIndex: lIndex,
      jungseongIndex: vIndex,
      jongseongIndex: tIndex,
      formula: jongseong.isNotEmpty
          ? '[$choseong + $jungseong + $jongseong = $syllable]'
          : '[$choseong + $jungseong = $syllable]',
      romanization: '${choseongRoman[lIndex]}${jungseongRoman[vIndex]}${jongseongRoman[tIndex]}',
    );
  }

  /// Decomposes an entire Hangul string into a list of [HangulDecomposition].
  /// Non-Hangul characters are skipped or returned with simple representation.
  static List<HangulDecomposition> decomposeString(String text) {
    final list = <HangulDecomposition>[];
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final decomp = decomposeChar(char);
      if (decomp != null) {
        list.add(decomp);
      }
    }
    return list;
  }

  /// Generates the mathematical formula breakdown representation:
  /// e.g. "감사" -> "[ㄱ + ㅏ + ㅁ = 감] [ㅅ + ㅏ = 사]"
  static String formatFormula(String hangulText) {
    final decompositions = decomposeString(hangulText);
    if (decompositions.isEmpty) return hangulText;
    return decompositions.map((d) => d.formula).join(' ');
  }

  /// Returns true if the final Hangul syllable of [word] has a Batchim (종성).
  ///
  /// Example:
  /// - `hasBatchim("선생님")` -> true (ㅁ)
  /// - `hasBatchim("사과")` -> false (none)
  /// - `hasBatchim("밥")` -> true (ㅂ)
  static bool hasBatchim(String word) {
    if (word.isEmpty) return false;
    // Find the last Hangul syllable in the word
    for (int i = word.length - 1; i >= 0; i--) {
      final code = word.codeUnitAt(i);
      if (isHangulSyllableCode(code)) {
        final sIndex = code - hangulBase;
        final tIndex = sIndex % jongseongCount;
        return tIndex > 0;
      }
    }
    return false;
  }

  /// Returns the Jongseong (Batchim) index for the last Hangul syllable.
  /// 0 means no batchim, 8 means 'ㄹ' (Rieul).
  static int getFinalBatchimIndex(String word) {
    if (word.isEmpty) return 0;
    for (int i = word.length - 1; i >= 0; i--) {
      final code = word.codeUnitAt(i);
      if (isHangulSyllableCode(code)) {
        final sIndex = code - hangulBase;
        return sIndex % jongseongCount;
      }
    }
    return 0;
  }

  /// Returns true if the final syllable ends with the batchim 'ㄹ' (Rieul, index 8).
  /// This is essential for the particle rule (으)로:
  /// - Words ending in vowels or 'ㄹ' take '로' (e.g. 지하철 -> 지하철로, 서울 -> 서울로)
  /// - Words ending in other consonants take '으로' (e.g. 연필 -> 연필로, 집 -> 집으로, 밥 -> 밥으로)
  static bool endsWithRieulBatchim(String word) {
    return getFinalBatchimIndex(word) == 8;
  }

  /// Returns the appropriate Topic Particle (은/는) based on batchim.
  static String getTopicParticle(String word) {
    return hasBatchim(word) ? '은' : '는';
  }

  /// Returns the appropriate Subject Particle (이/가) based on batchim.
  static String getSubjectParticle(String word) {
    return hasBatchim(word) ? '이' : '가';
  }

  /// Returns the appropriate Object Particle (을/를) based on batchim.
  static String getObjectParticle(String word) {
    return hasBatchim(word) ? '을' : '를';
  }

  /// Returns the appropriate Instrument/Direction Particle (으로/로).
  /// Rule: If no batchim OR final batchim is 'ㄹ', use '로'. Otherwise use '으로'.
  static String getInstrumentParticle(String word) {
    if (!hasBatchim(word) || endsWithRieulBatchim(word)) {
      return '로';
    }
    return '으로';
  }

  /// Reassembles a syllable from its components.
  static String composeChar(int choseongIndex, int jungseongIndex, [int jongseongIndex = 0]) {
    if (choseongIndex < 0 || choseongIndex >= 19) return '';
    if (jungseongIndex < 0 || jungseongIndex >= 21) return '';
    if (jongseongIndex < 0 || jongseongIndex >= 28) return '';
    final code = hangulBase + (choseongIndex * syllableCount) + (jungseongIndex * jongseongCount) + jongseongIndex;
    return String.fromCharCode(code);
  }
}

/// Representation of a decomposed Hangul Syllable.
class HangulDecomposition {
  final String syllable;
  final String choseong;
  final String jungseong;
  final String jongseong;
  final bool hasBatchim;
  final int choseongIndex;
  final int jungseongIndex;
  final int jongseongIndex;
  final String formula;
  final String romanization;

  const HangulDecomposition({
    required this.syllable,
    required this.choseong,
    required this.jungseong,
    required this.jongseong,
    required this.hasBatchim,
    required this.choseongIndex,
    required this.jungseongIndex,
    required this.jongseongIndex,
    required this.formula,
    required this.romanization,
  });

  @override
  String toString() => formula;
}
