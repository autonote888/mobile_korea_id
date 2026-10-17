import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/engine/korean_grammar_engine.dart';
import 'tts_speaker_button.dart';
import 'turtle_slow_button.dart';

/// Interactive Breakdown Card rendering SOV structure tags,
/// particle injection rationale, and formality switching.
class GrammarBreakdownCard extends StatefulWidget {
  final GrammarSentenceResult result;

  const GrammarBreakdownCard({
    super.key,
    required this.result,
  });

  @override
  State<GrammarBreakdownCard> createState() => _GrammarBreakdownCardState();
}

class _GrammarBreakdownCardState extends State<GrammarBreakdownCard> {
  FormalityLevel _currentFormality = FormalityLevel.informalPolite;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayedSentence = widget.result.getSentenceByFormality(_currentFormality);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: SOV Structure Badge & Audio Button (Overflow Safe)
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      widget.result.sovPattern,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryIndigo,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TurtleSlowButton(
                text: displayedSentence,
                size: 20,
              ),
              const SizedBox(width: 4),
              TtsSpeakerButton(
                text: displayedSentence,
                size: 22,
                activeColor: AppTheme.primaryIndigo,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Hangul Result Banner (Arti -> Cara Baca -> Aksara Hangul)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF1E293B)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Arti / Teks Asli
                Row(
                  children: [
                    Text(
                      'Arti: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.accentMint : const Color(0xFF065F46),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.result.originalInput,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 2. Cara Baca / Romanisasi Pelafalan
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Bacaan',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '[${widget.result.getRomanizationByFormality(_currentFormality)}]',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentCyan,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3. Tulisan Aksara Hangul
                Text(
                  displayedSentence,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.primaryDarkIndigo,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Formality Selector Chips
          Text(
            'Tingkat Kesopanan (Formality Level):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFormalityChip('Informal (-아요/어요)', FormalityLevel.informalPolite),
                const SizedBox(width: 6),
                _buildFormalityChip('Formal (-ㅂ니다/습니다)', FormalityLevel.formalPolite),
                const SizedBox(width: 6),
                _buildFormalityChip('Lampau (-았/었어요)', FormalityLevel.pastTense),
                const SizedBox(width: 6),
                _buildFormalityChip('Masa Depan (-(으)ㄹ 거예요)', FormalityLevel.futureTense),
                const SizedBox(width: 6),
                _buildFormalityChip('Kamus (-다)', FormalityLevel.baseDictionary),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Component Tag/Badge Breakdown (S - O - V)
          Text(
            'Bedah Komponen & Deteksi Partikel Cerdas:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),
          ...widget.result.tokens.map((token) => _buildTokenRow(context, token, isDark)),

          const SizedBox(height: 14),
          // Rule Explanation Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: AppTheme.accentAmber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.result.grammaticalSummary,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormalityChip(String label, FormalityLevel level) {
    final isSelected = _currentFormality == level;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentFormality = level;
          });
        }
      },
      selectedColor: AppTheme.primaryIndigo,
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.primaryIndigo,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryIndigo : AppTheme.primaryIndigo.withValues(alpha: 0.3),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildTokenRow(BuildContext context, GrammarToken token, bool isDark) {
    Color badgeColor;
    Color badgeBg;

    switch (token.role) {
      case GrammarRole.subject:
        badgeColor = AppTheme.subjectColor;
        badgeBg = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : AppTheme.subjectColorBg;
        break;
      case GrammarRole.location:
        badgeColor = AppTheme.locationColor;
        badgeBg = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : AppTheme.locationColorBg;
        break;
      case GrammarRole.instrument:
        badgeColor = AppTheme.accentMint;
        badgeBg = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5);
        break;
      case GrammarRole.time:
        badgeColor = const Color(0xFFD97706);
        badgeBg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF3C7);
        break;
      case GrammarRole.object:
        badgeColor = AppTheme.objectColor;
        badgeBg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : AppTheme.objectColorBg;
        break;
      case GrammarRole.predicate:
        badgeColor = AppTheme.predicateColor;
        badgeBg = isDark ? const Color(0xFF581C87).withValues(alpha: 0.3) : AppTheme.predicateColorBg;
        break;
      case GrammarRole.standalone:
        badgeColor = AppTheme.primaryIndigo;
        badgeBg = isDark ? const Color(0xFF1E1B4B).withValues(alpha: 0.3) : const Color(0xFFEEF2FF);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Role Badge on Left (Flexible + ellipsis), Audio Controls on Right (Zero overflow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      token.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TurtleSlowButton(
                      text: token.fullKorean,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    TtsSpeakerButton(
                      text: token.fullKorean,
                      size: 16,
                      color: badgeColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 1. Kata / Arti & Cara Baca (Romanisasi) - Full Width
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 2,
              children: [
                Text(
                  token.originalText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  '[${token.romanization}]',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 2. Aksara Hangul & Partikel - Full Width
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 2,
              children: [
                Text(
                  token.koreanCore,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
                if (token.particle != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+ ${token.particle}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ),
                  Text(
                    '➔ ${token.fullKorean}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.primaryDarkIndigo,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // 3. Penjelasan Tata Bahasa Partikel
            Text(
              token.explanation,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
