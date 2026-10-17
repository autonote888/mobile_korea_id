import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/engine/korean_grammar_engine.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/dictionary_item.dart';
import '../widgets/korean_spelling_card.dart';
import '../widgets/tts_speaker_button.dart';
import '../widgets/turtle_slow_button.dart';

/// Halaman 2: Kamus Trilingual (Korea - Indonesia - Inggris) 100% Offline.
class TabDictionary extends StatefulWidget {
  const TabDictionary({super.key});

  @override
  State<TabDictionary> createState() => _TabDictionaryState();
}

class _TabDictionaryState extends State<TabDictionary> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<DictionaryItem> _items = [];
  bool _isLoading = true;
  String _selectedPos = 'Semua';

  final List<String> _posFilters = [
    'Semua',
    'Noun',
    'Verb',
    'Adjective',
    'Particle',
    'Phrase',
    'Pronoun',
  ];

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _loadDictionary();
    });
  }

  Future<void> _loadDictionary() async {
    setState(() => _isLoading = true);
    final query = _searchController.text.trim();
    final results = await DatabaseHelper.instance.searchDictionary(
      query,
      posFilter: _selectedPos,
    );
    if (mounted) {
      setState(() {
        _items = results;
        _isLoading = false;
      });
    }
  }

  void _showItemDetails(DictionaryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final isVerbOrAdj = item.pos == 'Verb' || item.pos == 'Adjective';
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Hangul, Reading & Audio Buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.koreanHangul,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.textPrimaryDark : AppTheme.primaryDarkIndigo,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Bacaan: [${item.koreanRoman}]',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPosColor(item.pos).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(color: _getPosColor(item.pos).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          item.pos,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _getPosColor(item.pos),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TurtleSlowButton(text: item.koreanHangul, size: 22),
                      const SizedBox(width: 4),
                      TtsSpeakerButton(text: item.koreanHangul, size: 24),
                    ],
                  ),
                  const Divider(height: 28),

                  // Translations Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTranslationRow('🇮🇩 Indonesia', item.indonesian, isDark),
                        const SizedBox(height: 8),
                        _buildTranslationRow('🇬🇧 English', item.english, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conjugation card if Verb or Adjective
                  if (isVerbOrAdj && item.baseVerb != null && item.baseVerb!.isNotEmpty) ...[
                    _buildConjugationBox(item.baseVerb!, isDark),
                    const SizedBox(height: 16),
                  ],

                  // Syllable deconstruction card
                  KoreanSpellingCard(
                    hangulText: item.koreanHangul,
                    title: 'Analisis Suku Kata & Batchim',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTranslationRow(String flagLabel, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            flagLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConjugationBox(String baseVerb, bool isDark) {
    final informal = KoreanGrammarEngine.conjugateInformalPolite(baseVerb);
    final formal = KoreanGrammarEngine.conjugateFormalPolite(baseVerb);
    final past = KoreanGrammarEngine.conjugatePastTense(baseVerb);
    final future = KoreanGrammarEngine.conjugateFutureTense(baseVerb);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.predicateColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.predicateColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_alt_rounded, size: 16, color: AppTheme.predicateColor),
              const SizedBox(width: 6),
              const Text(
                'Tabel Konjugasi Predikat Otomatis:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.predicateColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildConjugationRow('Kamus Dasar', baseVerb, isDark),
          _buildConjugationRow('Informal Sopan (-아요/어요)', informal, isDark),
          _buildConjugationRow('Formal Sopan (-ㅂ니다/습니다)', formal, isDark),
          _buildConjugationRow('Bentuk Lampau (-았/었어요)', past, isDark),
          _buildConjugationRow('Rencana/Masa Depan (-(으)ㄹ 거예요)', future, isDark),
        ],
      ),
    );
  }

  Widget _buildConjugationRow(String title, String result, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          Text(
            result,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPosColor(String pos) {
    switch (pos) {
      case 'Noun':
        return AppTheme.subjectColor;
      case 'Verb':
        return AppTheme.predicateColor;
      case 'Adjective':
        return AppTheme.accentCoral;
      case 'Particle':
        return AppTheme.accentCyan;
      case 'Phrase':
        return AppTheme.accentMint;
      case 'Pronoun':
        return AppTheme.accentAmber;
      default:
        return AppTheme.primaryIndigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.accentMint,
                          size: 20,
                        ),
                      ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kamus Trilingual Offline',
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
                                'Bahasa Korea • Indonesia • Inggris (${_items.length} kosakata)',
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
                  const SizedBox(height: 14),

                  // Search Bar with Debounce
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      ),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari dalam Hangul, Romanisasi, ID, atau EN...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryIndigo),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadDictionary();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // POS Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _posFilters.map((pos) {
                        final isSelected = _selectedPos == pos;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(pos),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedPos = pos);
                                _loadDictionary();
                              }
                            },
                            selectedColor: AppTheme.primaryIndigo,
                            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryIndigo : Colors.transparent,
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

            // Dictionary List View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 54,
                                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada kosakata yang cocok',
                                style: TextStyle(
                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: _items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final posColor = _getPosColor(item.pos);

                            return InkWell(
                              onTap: () => _showItemDetails(item),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(
                                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                  ),
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 1. Text Info: Arti -> Bacaan [roman] -> Aksara Hangul
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Baris 1: Arti (ID) & Bacaan (Romanisasi)
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  item.indonesian,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentCyan.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '[${item.koreanRoman}]',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.accentCyan,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),

                                          // Baris 2: Aksara Hangul & Bahasa Inggris
                                          Row(
                                            children: [
                                              Text(
                                                item.koreanHangul,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark ? Colors.white : AppTheme.primaryDarkIndigo,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: Text(
                                                  item.english,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 2. Right Side: POS Badge + TurtleSlowButton + TtsSpeakerButton
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: posColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: posColor.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            item.pos,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: posColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        TurtleSlowButton(text: item.koreanHangul, size: 17),
                                        TtsSpeakerButton(text: item.koreanHangul, size: 18),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
