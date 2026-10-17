import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_korea_id/core/engine/hangul_speller.dart';
import 'package:mobile_korea_id/core/engine/korean_grammar_engine.dart';
import 'package:mobile_korea_id/data/models/dictionary_item.dart';
import 'package:mobile_korea_id/data/repositories/standard_practice_repository.dart';

void main() {
  group('HangulSpeller Unicode Mathematical Deconstructor Tests', () {
    test('Deconstructs syllable with batchim correctly', () {
      final decomp = HangulSpeller.decomposeChar('감');
      expect(decomp, isNotNull);
      expect(decomp!.choseong, 'ㄱ');
      expect(decomp.jungseong, 'ㅏ');
      expect(decomp.jongseong, 'ㅁ');
      expect(decomp.hasBatchim, isTrue);
      expect(decomp.formula, '[ㄱ + ㅏ + ㅁ = 감]');
    });

    test('Deconstructs syllable without batchim correctly', () {
      final decomp = HangulSpeller.decomposeChar('사');
      expect(decomp, isNotNull);
      expect(decomp!.choseong, 'ㅅ');
      expect(decomp.jungseong, 'ㅏ');
      expect(decomp.jongseong, '');
      expect(decomp.hasBatchim, isFalse);
      expect(decomp.formula, '[ㅅ + ㅏ = 사]');
    });

    test('Formats full word formula breakdown: 감사 -> [ㄱ + ㅏ + ㅁ = 감] [ㅅ + ㅏ = 사]', () {
      final formula = HangulSpeller.formatFormula('감사');
      expect(formula, '[ㄱ + ㅏ + ㅁ = 감] [ㅅ + ㅏ = 사]');
    });

    test('Detects batchim existence accurately', () {
      expect(HangulSpeller.hasBatchim('선생님'), isTrue); // ㅁ
      expect(HangulSpeller.hasBatchim('사과'), isFalse); // none
      expect(HangulSpeller.hasBatchim('밥'), isTrue); // ㅂ
      expect(HangulSpeller.hasBatchim('나'), isFalse); // none
    });

    test('Selects topic particles 은 / 는 accurately', () {
      expect(HangulSpeller.getTopicParticle('선생님'), '은');
      expect(HangulSpeller.getTopicParticle('나'), '는');
      expect(HangulSpeller.getTopicParticle('저'), '는');
    });

    test('Selects object particles 을 / 를 accurately', () {
      expect(HangulSpeller.getObjectParticle('밥'), '을');
      expect(HangulSpeller.getObjectParticle('사과'), '를');
      expect(HangulSpeller.getObjectParticle('책'), '을');
    });

    test('Rieul batchim rule for (으)로 particle: 지하철로 vs 집으로', () {
      expect(HangulSpeller.endsWithRieulBatchim('지하철'), isTrue);
      expect(HangulSpeller.getInstrumentParticle('지하철'), '로');
      expect(HangulSpeller.getInstrumentParticle('버스'), '로'); // vowel ending -> 로
      expect(HangulSpeller.getInstrumentParticle('집'), '으로'); // consonant ending -> 으로
      expect(HangulSpeller.getInstrumentParticle('밥'), '으로');
    });

    test('Romanizes Hangul text accurately: 빵 -> ppang, 밥 -> bap, 사과 -> sagwa', () {
      expect(HangulSpeller.romanizeText('빵'), 'ppang');
      expect(HangulSpeller.romanizeText('밥'), 'bap');
      expect(HangulSpeller.romanizeText('사과'), 'sagwa');
    });
  });

  group('KoreanGrammarEngine Deterministic SOV Tests', () {
    test('Predicate conjugations for regular & hada verbs', () {
      // Informal polite (-아요/어요/해요)
      expect(KoreanGrammarEngine.conjugateInformalPolite('먹다'), '먹어요');
      expect(KoreanGrammarEngine.conjugateInformalPolite('가다'), '가요');
      expect(KoreanGrammarEngine.conjugateInformalPolite('공부하다'), '공부해요');
      expect(KoreanGrammarEngine.conjugateInformalPolite('보다'), '봐요');
      expect(KoreanGrammarEngine.conjugateInformalPolite('마시다'), '마셔요');

      // Formal polite (-ㅂ니다/습니다)
      expect(KoreanGrammarEngine.conjugateFormalPolite('먹다'), '먹습니다');
      expect(KoreanGrammarEngine.conjugateFormalPolite('가다'), '갑니다');
      expect(KoreanGrammarEngine.conjugateFormalPolite('공부하다'), '공부합니다');
      expect(KoreanGrammarEngine.conjugateFormalPolite('만들다'), '만듭니다'); // ㄹ irregular drops
    });

    test('Transforms S-V-O into S-O-V with smart particle injection', () {
      final result = KoreanGrammarEngine.parseSentence('Saya makan nasi');
      expect(result.tokens.length, 3);
      expect(result.tokens[0].role, GrammarRole.subject);
      expect(result.tokens[0].fullKorean, '저는');
      expect(result.tokens[1].role, GrammarRole.object);
      expect(result.tokens[1].fullKorean, '밥을');
      expect(result.tokens[2].role, GrammarRole.predicate);
      expect(result.informalSentence, '저는 밥을 먹어요');
      expect(result.formalSentence, '저는 밥을 먹습니다');
    });

    test('Transforms sentence with location: Budi membaca buku di perpustakaan', () {
      final result = KoreanGrammarEngine.parseSentence('Budi membaca buku di perpustakaan');
      expect(result.informalSentence, '부디는 도서관에서 책을 읽어요');
    });

    test('Transforms new situational vocabulary: supermarket, bread, student', () {
      final r1 = KoreanGrammarEngine.parseSentence('Saya makan roti');
      expect(r1.informalSentence, '저는 빵을 먹어요');

      final r2 = KoreanGrammarEngine.parseSentence('Saya pergi ke supermarket');
      expect(r2.informalSentence, '저는 마트에 가요');

      final r3 = KoreanGrammarEngine.parseSentence('Mahasiswa belajar bahasa Korea');
      expect(r3.informalSentence, '대학생은 한국어를 공부해요');
    });
  });

  group('DictionaryItem Model & Category Tests', () {
    test('Serializes and deserializes category property accurately', () {
      final item = DictionaryItem(
        indonesian: 'Supermarket / Mart',
        english: 'Supermarket',
        koreanHangul: '마트',
        koreanRoman: 'mateu',
        pos: 'Noun',
        category: 'Belanja & Supermarket',
      );

      final map = item.toMap();
      expect(map['category'], 'Belanja & Supermarket');

      final fromMapItem = DictionaryItem.fromMap(map);
      expect(fromMapItem.category, 'Belanja & Supermarket');
      expect(fromMapItem.koreanHangul, '마트');
    });
  });

  group('StandardPracticeRepository & Official Curriculum Tests', () {
    test('Retrieves 7 official EPS-TOPIK learning levels', () {
      final levels = StandardPracticeRepository.getAllLevels();
      expect(levels.length, 7);
      expect(levels[0].levelNumber, 1);
      expect(levels[6].levelNumber, 7);
      expect(levels[0].bookVolume.contains('Jilid 1'), isTrue);
      expect(levels[6].bookVolume.contains('Jilid 2'), isTrue);
    });

    test('Retrieves specific chapter by Bab number', () {
      final bab1 = StandardPracticeRepository.getChapterByBab(1);
      expect(bab1, isNotNull);
      expect(bab1!.titleKo, '자기소개');
      expect(bab1.dialogues.isNotEmpty, isTrue);
      expect(bab1.vocabularies.isNotEmpty, isTrue);
      expect(bab1.grammarList.isNotEmpty, isTrue);
      expect(bab1.exercises.isNotEmpty, isTrue);

      final bab57 = StandardPracticeRepository.getChapterByBab(57);
      expect(bab57, isNotNull);
      expect(bab57!.titleKo, '고용허가제');
      expect(bab57.volume, 'Jilid 2');
    });

    test('Searches chapters by keyword', () {
      final searchResults = StandardPracticeRepository.searchChapters('자기소개');
      expect(searchResults.isNotEmpty, isTrue);
      expect(searchResults.first.babNumber, 1);

      final searchFood = StandardPracticeRepository.searchChapters('restoran');
      expect(searchFood.isNotEmpty, isTrue);
    });
  });
}
