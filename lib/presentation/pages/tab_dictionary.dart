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
/// Dilengkapi pembagian aktivitas tematik (Perkenalan Diri, Belanja/Mart, Tidur/Rutinitas, Arah Jalan, dll.),
/// Pronoun lengkap (saya, kamu, kami, kita, bersama, sendiri), audio normal & kura-kura lambat,
/// dan tata letak yang 100% responsif bebas overflow/overload.
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

  String _selectedCategory = 'Semua Kegiatan';
  String _selectedPos = 'Semua';

  final List<String> _categoryFilters = [
    'Semua Kegiatan',
    'Perkenalan Diri',
    'Kata Ganti & Sosial',
    'Belanja & Supermarket',
    'Tidur & Rutinitas',
    'Arah & Jalan',
    'Restoran & Makan',
    'Transportasi',
    'Kesehatan & Darurat',
    'Kantor & Belajar',
    'Emosi & Cuaca',
    'Percakapan Umum',
    'Tata Bahasa & Partikel',
  ];

  final List<String> _posFilters = [
    'Semua',
    'Pronoun',
    'Noun',
    'Verb',
    'Adjective',
    'Adverb',
    'Phrase',
    'Particle',
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
      categoryFilter: _selectedCategory,
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
          initialChildSize: 0.70,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final isVerbOrAdj = item.pos == 'Verb' || item.pos == 'Adjective';
            final catColor = _getCategoryColor(item.category);
            final posColor = _getPosColor(item.pos);

            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Badges Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(color: catColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: catColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: posColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(color: posColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          item.pos,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: posColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TurtleSlowButton(text: item.koreanHangul, size: 22),
                      const SizedBox(width: 4),
                      TtsSpeakerButton(text: item.koreanHangul, size: 24),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Main Hangul Title (Multi-line safe)
                  SelectableText(
                    item.koreanHangul,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.primaryDarkIndigo,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Pronunciation / Reading
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Bacaan: [${item.koreanRoman}]',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ),
                  const Divider(height: 28),

                  // Translations Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTranslationRow('Arti (ID)', item.indonesian, isDark),
                        const SizedBox(height: 10),
                        _buildTranslationRow('English', item.english, isDark),
                        if (item.sentencePattern != null && item.sentencePattern!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildTranslationRow('Pola / Peran', item.sentencePattern!, isDark),
                        ],
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

  Widget _buildTranslationRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              height: 1.3,
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
          const Row(
            children: [
              Icon(Icons.sync_alt_rounded, size: 16, color: AppTheme.predicateColor),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tabel Konjugasi Predikat Otomatis:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.predicateColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildConjugationRow('Kamus Dasar', baseVerb, isDark),
          _buildConjugationRow('Informal Sopan (-아요/어요)', informal, isDark),
          _buildConjugationRow('Formal Sopan (-ㅂ니다/습니다)', formal, isDark),
          _buildConjugationRow('Bentuk Lampau (-았/었어요)', past, isDark),
          _buildConjugationRow('Masa Depan (-(으)ㄹ 거예요)', future, isDark),
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
          Flexible(
            flex: 6,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 5,
            child: Text(
              result,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Perkenalan Diri':
        return AppTheme.primaryIndigo;
      case 'Kata Ganti & Sosial':
        return AppTheme.accentAmber;
      case 'Belanja & Supermarket':
        return AppTheme.accentMint;
      case 'Tidur & Rutinitas':
        return const Color(0xFF8B5CF6);
      case 'Arah & Jalan':
        return AppTheme.accentCyan;
      case 'Restoran & Makan':
        return AppTheme.accentCoral;
      case 'Transportasi':
        return const Color(0xFF0284C7);
      case 'Kesehatan & Darurat':
        return const Color(0xFFEF4444);
      case 'Kantor & Belajar':
        return const Color(0xFF10B981);
      case 'Emosi & Cuaca':
        return const Color(0xFFF59E0B);
      case 'Percakapan Umum':
        return AppTheme.primaryDarkIndigo;
      case 'Tata Bahasa & Partikel':
        return AppTheme.accentCyan;
      default:
        return AppTheme.primaryIndigo;
    }
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
      case 'Adverb':
        return const Color(0xFF8B5CF6);
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
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
                  const SizedBox(height: 12),

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
                        fontSize: 14,
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

                  // Category Activity Filter Chips (Belanja, Tidur, Arah, Perkenalan, dll)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _categoryFilters.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = cat);
                                _loadDictionary();
                              }
                            },
                            selectedColor: AppTheme.primaryIndigo,
                            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
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
                  const SizedBox(height: 6),

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
                            selectedColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.white : AppTheme.primaryDarkIndigo)
                                  : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              side: BorderSide(
                                color: isSelected
                                    ? (isDark ? AppTheme.borderDark : AppTheme.primaryIndigo)
                                    : (isDark ? Colors.white12 : Colors.black12),
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

            // Dictionary List View (Guaranteed 100% Overflow-Free)
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
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          itemCount: _items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final catColor = _getCategoryColor(item.category);
                            final posColor = _getPosColor(item.pos);

                            return InkWell(
                              onTap: () => _showItemDetails(item),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(
                                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                  ),
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Baris 1: Arti (ID) & Tag Kategori
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.indonesian,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            border: Border.all(color: catColor.withValues(alpha: 0.25)),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: catColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Baris 2: Bacaan / Romanisasi & Arti Bahasa Inggris
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentCyan.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '[${item.koreanRoman}]',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.accentCyan,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        if (item.english.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Flexible(
                                            flex: 5,
                                            child: Text(
                                              item.english,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? AppTheme.textSecondaryDark
                                                    : AppTheme.textSecondaryLight,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Baris 3: Aksara Hangul & Tombol Audio
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.koreanHangul,
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : AppTheme.primaryDarkIndigo,
                                              letterSpacing: -0.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              margin: const EdgeInsets.only(right: 3),
                                              decoration: BoxDecoration(
                                                color: posColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
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
                                            TurtleSlowButton(text: item.koreanHangul, size: 17),
                                            const SizedBox(width: 2),
                                            TtsSpeakerButton(text: item.koreanHangul, size: 18),
                                          ],
                                        ),
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
