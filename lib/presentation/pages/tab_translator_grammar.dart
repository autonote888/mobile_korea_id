import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/engine/korean_grammar_engine.dart';
import '../widgets/grammar_breakdown_card.dart';
import '../widgets/korean_spelling_card.dart';
import 'custom_self_intro_page.dart';

/// Halaman 1: Translator & Deterministic Grammar Parser (S-V-O ➔ S-O-V).
/// Runs 100% offline with zero battery & CPU drain.
/// Supports arbitrary sentences, short words, and instant auto-update with Enter button.
class TabTranslatorGrammar extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const TabTranslatorGrammar({super.key, this.onNavigateTab});

  @override
  State<TabTranslatorGrammar> createState() => _TabTranslatorGrammarState();
}

class _TabTranslatorGrammarState extends State<TabTranslatorGrammar> {
  final TextEditingController _inputController = TextEditingController();
  GrammarSentenceResult? _currentResult;

  final List<String> _quickTemplates = [
    'Saya makan roti',
    'Makan nasi di rumah',
    'Saya pergi ke supermarket',
    'Ke pasar',
    'Roti',
    'Belajar',
    'Terima kasih',
    'Budi membaca buku di perpustakaan',
    'Saya dan teman belajar bahasa Korea',
    'Cantik',
    'Mahasiswa belajar bahasa Korea',
    'Adik minum susu di rumah',
    'Saya membeli obat di apotek',
  ];

  @override
  void initState() {
    super.initState();
    _inputController.text = _quickTemplates[0];
    _inputController.addListener(_onInputChanged);
    _analyzeCurrent();
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    _analyzeCurrent();
  }

  void _analyzeCurrent() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      if (mounted) {
        setState(() {
          _currentResult = null;
        });
      }
      return;
    }
    final result = KoreanGrammarEngine.parseSentence(text);
    if (mounted) {
      setState(() {
        _currentResult = result;
      });
    }
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
            // App Bar Title (Overflow Safe)
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
                        Expanded(
                          child: Column(
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Dapat mengetik kata tunggal atau kalimat panjang bebas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Custom Self-Introduction Studio Banner Shortcut
                    InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(2);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomSelfIntroPage(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    AppTheme.primaryIndigo.withValues(alpha: 0.25),
                                    AppTheme.locationColor.withValues(alpha: 0.15),
                                  ]
                                : [
                                    AppTheme.primaryIndigo.withValues(alpha: 0.1),
                                    AppTheme.locationColor.withValues(alpha: 0.05),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.badge_rounded,
                              size: 20,
                              color: AppTheme.primaryIndigo,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Kustom Perkenalan Diri (자기소개)',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.primaryIndigo,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentCoral,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'BARU',
                                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Atur nama, pekerjaan sebelumnya, lulusan sekolah & asal',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppTheme.primaryIndigo,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick Shortcuts Row for other menus
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildQuickMenuChip(
                            label: 'Kamus (1.259+)',
                            icon: Icons.menu_book_rounded,
                            onTap: () => widget.onNavigateTab?.call(1),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          _buildQuickMenuChip(
                            label: 'Kenal Diri',
                            icon: Icons.badge_rounded,
                            onTap: () => widget.onNavigateTab?.call(2),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          _buildQuickMenuChip(
                            label: 'Hafalan Saya',
                            icon: Icons.fact_check_rounded,
                            onTap: () => widget.onNavigateTab?.call(3),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          _buildQuickMenuChip(
                            label: 'Materi EPS (60 Bab)',
                            icon: Icons.school_rounded,
                            onTap: () => widget.onNavigateTab?.call(4),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          _buildQuickMenuChip(
                            label: 'Ujian TOPIK',
                            icon: Icons.military_tech_rounded,
                            onTap: () => widget.onNavigateTab?.call(5),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Modern Input Field with Enter Button
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
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _analyzeCurrent(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ketik kata atau kalimat apapun...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                ),
                                prefixIcon: const Icon(
                                  Icons.translate_rounded,
                                  color: AppTheme.primaryIndigo,
                                  size: 20,
                                ),
                                suffixIcon: _inputController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _inputController.clear();
                                          _analyzeCurrent();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          // Dedicated Jalankan (Enter) Action Button
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ElevatedButton.icon(
                              onPressed: _analyzeCurrent,
                              icon: const Icon(Icons.keyboard_return_rounded, size: 16),
                              label: const Text('Enter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryIndigo,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick-fill template chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _quickTemplates.map((template) {
                          final isSelected = _inputController.text.trim().toLowerCase() == template.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
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

            // Grammar Analysis & Cards (Keyed for instant UI rebuild on every change)
            if (_currentResult != null && _currentResult!.tokens.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: GrammarBreakdownCard(
                    key: ValueKey(
                      '${_currentResult!.originalInput}_${_currentResult!.informalSentence}_${_currentResult!.sovPattern}',
                    ),
                    result: _currentResult!,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: KoreanSpellingCard(
                    key: ValueKey(
                      'spelling_${_currentResult!.informalSentence}',
                    ),
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
                        'Ketik kata atau kalimat di atas, lalu tekan Enter',
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

  Widget _buildQuickMenuChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.primaryIndigo),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

