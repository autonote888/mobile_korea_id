import '../../core/engine/hangul_speller.dart';

class DictionaryItem {
  final int? id;
  final String indonesian;
  final String english;
  final String koreanHangul;
  final String koreanRoman;
  final String pos; // Noun, Verb, Adjective, Particle, Phrase, Pronoun
  final String? sentencePattern; // S, O, Place, V, A, Instrument
  final String? baseVerb;

  const DictionaryItem({
    this.id,
    required this.indonesian,
    required this.english,
    required this.koreanHangul,
    required this.koreanRoman,
    required this.pos,
    this.sentencePattern,
    this.baseVerb,
  });

  factory DictionaryItem.fromMap(Map<String, dynamic> map) {
    return DictionaryItem(
      id: map['id'] as int?,
      indonesian: map['indonesian'] as String? ?? '',
      english: map['english'] as String? ?? '',
      koreanHangul: map['korean_hangul'] as String? ?? '',
      koreanRoman: map['korean_roman'] as String? ?? '',
      pos: map['pos'] as String? ?? 'Noun',
      sentencePattern: map['sentence_pattern'] as String?,
      baseVerb: map['base_verb'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'indonesian': indonesian,
      'english': english,
      'korean_hangul': koreanHangul,
      'korean_roman': koreanRoman,
      'pos': pos,
      'sentence_pattern': sentencePattern,
      'base_verb': baseVerb,
    };
  }

  bool get hasBatchim => HangulSpeller.hasBatchim(koreanHangul);

  String get spellingFormula => HangulSpeller.formatFormula(koreanHangul);

  List<HangulDecomposition> get decompositions => HangulSpeller.decomposeString(koreanHangul);
}
