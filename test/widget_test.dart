import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_korea_id/core/engine/hangul_speller.dart';
import 'package:mobile_korea_id/core/engine/korean_grammar_engine.dart';

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
  });
}
