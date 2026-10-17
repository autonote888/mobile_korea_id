import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/exam_model.dart';
import 'quiz_screen.dart';

/// Halaman 3: Latihan Ujian Bertingkat (Level 1 Dasar s.d. Level 4 TOPIK).
class TabExamLevels extends StatefulWidget {
  const TabExamLevels({super.key});

  @override
  State<TabExamLevels> createState() => _TabExamLevelsState();
}

class _TabExamLevelsState extends State<TabExamLevels> {
  List<ExamPackage> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    final packages = await DatabaseHelper.instance.getExamPackages();
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  void _startQuiz(ExamPackage package) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(package: package),
      ),
    );
    if (result == true) {
      _loadPackages();
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return AppTheme.accentMint;
      case 2:
        return AppTheme.accentCyan;
      case 3:
        return AppTheme.primaryIndigo;
      case 4:
        return AppTheme.accentCoral;
      default:
        return AppTheme.primaryIndigo;
    }
  }

  String _getLevelSubtitle(int level) {
    switch (level) {
      case 1:
        return 'Tren TOPIK I Terkini (15 Soal): Hangeul, Perkenalan, Belanja, Arah, & Partikel';
      case 2:
        return 'Pola SOV Alami, Keterangan Tempat (에서/에) & Sarana (로/으로)';
      case 3:
        return 'Konjugasi Informal (-아요/어요), Formal (-ㅂ니다/습니다), & Lampau';
      case 4:
        return 'TOPIK I Mastery, Bentuk Masa Depan, & Verba Tidak Beraturan';
      default:
        return 'Latihan Ujian Tata Bahasa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCoral.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.military_tech_rounded,
                                  color: AppTheme.accentCoral,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Latihan Ujian Bertingkat',
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
                                      'Level 1 Dasar s.d. Level 4 Standar TOPIK',
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

                          // Overall Summary Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                                    : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              boxShadow: AppTheme.cardShadowActive,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Uji Kecakapan Bahasa Korea',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Setiap paket dilengkapi audio TTS native dan kartu pembahasan dwibahasa (ID/EN) instan.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Packages List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final package = _packages[index];
                          final levelColor = _getLevelColor(package.level);
                          final hasScore = package.bestScore != null;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: InkWell(
                              onTap: () => _startQuiz(package),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  border: Border.all(
                                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                  ),
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Level Number Badge
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: levelColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Lv.${package.level}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: levelColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Package Title & Subtitle
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                package.title,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                _getLevelSubtitle(package.level),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  height: 1.3,
                                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                                      ],
                                    ),
                                    const Divider(height: 22),

                                    // Bottom Info Row: Total questions & Best score
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.quiz_outlined,
                                              size: 15,
                                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${package.totalQuestions} Soal Ujian',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (hasScore)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: (package.bestPercentage! >= 80 ? AppTheme.accentMint : AppTheme.accentAmber).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: package.bestPercentage! >= 80 ? AppTheme.accentMint : AppTheme.accentAmber,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Terbaik: ${package.bestScore}/${package.totalQuestions} (${package.bestPercentage!.toStringAsFixed(0)}%)',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: package.bestPercentage! >= 80 ? AppTheme.accentMint : AppTheme.accentAmber,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Text(
                                            'Belum dikerjakan',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _packages.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
