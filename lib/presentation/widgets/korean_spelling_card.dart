import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_theme.dart';
import '../../core/engine/hangul_speller.dart';
import 'tts_speaker_button.dart';
import 'turtle_slow_button.dart';

/// Interactive Card displaying the Unicode Syllable Decomposition
/// [초성 + 중성 + 종성 = 음절] with zero memory overhead.
class KoreanSpellingCard extends StatelessWidget {
  final String hangulText;
  final String title;

  const KoreanSpellingCard({
    super.key,
    required this.hangulText,
    this.title = 'Visualisasi Ejaan Suku Kata (HangulSpeller)',
  });

  @override
  Widget build(BuildContext context) {
    final decompositions = HangulSpeller.decomposeString(hangulText);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (decompositions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TurtleSlowButton(text: hangulText, size: 18),
              TtsSpeakerButton(text: hangulText, size: 18),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16),
                tooltip: 'Salin Formula Ejaan',
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                onPressed: () {
                  final formula = HangulSpeller.formatFormula(hangulText);
                  Clipboard.setData(ClipboardData(text: formula));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Formula berhasil disalin: $formula'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Wrap list of decomposed syllables
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: decompositions.map((d) => _buildSyllableChip(context, d, isDark)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSyllableChip(BuildContext context, HangulDecomposition d, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: d.hasBatchim
              ? AppTheme.accentMint.withValues(alpha: 0.4)
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Syllable + Sound
          Text(
            d.syllable,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryIndigo,
            ),
          ),
          const SizedBox(height: 2),
          // Formula breakdown
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLetterBadge(d.choseong, '초성', AppTheme.subjectColor),
              const Text(' + ', style: TextStyle(fontSize: 10, color: Colors.grey)),
              _buildLetterBadge(d.jungseong, '중성', AppTheme.objectColor),
              if (d.jongseong.isNotEmpty) ...[
                const Text(' + ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                _buildLetterBadge(d.jongseong, '받침', AppTheme.accentMint),
              ],
            ],
          ),
          if (d.romanization.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              '[${d.romanization}]',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLetterBadge(String char, String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        char,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
