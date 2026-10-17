import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/engine/korean_grammar_engine.dart';
import '../widgets/grammar_breakdown_card.dart';
import '../widgets/korean_spelling_card.dart';

/// Halaman 1: Translator & Deterministic Grammar Parser (S-V-O ➔ S-O-V).
/// Runs 100% offline with zero battery & CPU drain.
class TabTranslatorGrammar extends StatefulWidget {
  const TabTranslatorGrammar({super.key});

  @override
  State<TabTranslatorGrammar> createState() => _TabTranslatorGrammarState();
}

class _TabTranslatorGrammarState extends State<TabTranslatorGrammar> {
  final TextEditingController _inputController = TextEditingController();
  GrammarSentenceResult? _currentResult;

  final List<String> _quickTemplates = [
    'Saya makan nasi',
    'Budi membaca buku di perpustakaan',
    'Saya pergi ke sekolah',
    'Adik minum susu',
    'Saya belajar bahasa Korea',
    'I eat bread at home',
    'Minho menonton film di kafe',
  ];

  @override
  void initState() {
    super.initState();
    _inputController.text = _quickTemplates[0];
    _analyzeCurrent();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _analyzeCurrent() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _currentResult = null;
      });
      return;
    }
    final result = KoreanGrammarEngine.parseSentence(text);
    setState(() {
      _currentResult = result;
    });
  }

  void _selectTemplate(String template) {
    _inputController.text = template;
    _analyzeCurrent();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppTheme.primaryIndigo,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Struktur SOV & Parser Tata Bahasa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Transformasi Otomatis S-V-O ke S-O-V Korea',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Modern Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextField(
                        controller: _inputController,
                        onChanged: (val) => _analyzeCurrent(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan kalimat (contoh: Saya makan nasi)',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          ),
                          prefixIcon: const Icon(
                            Icons.translate_rounded,
                            color: AppTheme.primaryIndigo,
                            size: 22,
                          ),
                          suffixIcon: _inputController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  onPressed: () {
                                    _inputController.clear();
                                    _analyzeCurrent();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick-fill template chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _quickTemplates.map((template) {
                          final isSelected = _inputController.text.trim().toLowerCase() == template.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(template),
                              onPressed: () => _selectTemplate(template),
                              backgroundColor: isSelected
                                  ? AppTheme.primaryIndigo.withValues(alpha: 0.15)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primaryIndigo
                                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.primaryIndigo
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grammar Analysis & Cards
            if (_currentResult != null && _currentResult!.tokens.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: GrammarBreakdownCard(result: _currentResult!),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: KoreanSpellingCard(
                    hangulText: _currentResult!.informalSentence,
                    title: 'Dekonstruksi Fonetik HangulSpeller',
                  ),
                ),
              ),
            ] else ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 64,
                        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ketik atau pilih kalimat contoh di atas',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
