import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import 'tab_translator_grammar.dart';
import 'tab_dictionary.dart';
import 'custom_self_intro_page.dart';
import 'tab_memorized_checklist.dart';
import 'tab_standard_practice.dart';
import 'tab_exam_levels.dart';

/// Main Root Navigation Screen wrapping Material 3 NavigationBar and Navigation Drawer.
/// Integrates all 6 offline learning modules seamlessly.
class HomeNavigationScreen extends StatefulWidget {
  final ValueChanged<ThemeMode>? onThemeToggle;
  final ThemeMode currentThemeMode;

  const HomeNavigationScreen({
    super.key,
    this.onThemeToggle,
    this.currentThemeMode = ThemeMode.system,
  });

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TabTranslatorGrammar(onNavigateTab: _navigateToTab),
      const TabDictionary(),
      const CustomSelfIntroPage(isTab: true),
      const TabMemorizedChecklist(),
      const TabStandardPractice(),
      const TabExamLevels(),
    ];
  }

  void _navigateToTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                      : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '한국어',
                          style: TextStyle(
                            color: AppTheme.primaryIndigo,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: const Text(
                          '100% Offline Lokal',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Trilingual Korean Master',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '한국어 • Bahasa Indonesia • English',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Menu List Items
            _buildDrawerTile(
              index: 0,
              icon: Icons.translate_rounded,
              title: 'Parser SOV & Tata Bahasa',
              subtitle: 'Analisis struktur kalimat & konjugasi',
              isDark: isDark,
            ),
            _buildDrawerTile(
              index: 1,
              icon: Icons.menu_book_rounded,
              title: 'Kamus Trilingual (1.259+ Kata)',
              subtitle: '15 kategori aktivitas sehari-hari lengkap',
              isDark: isDark,
            ),
            _buildDrawerTile(
              index: 2,
              icon: Icons.badge_rounded,
              title: 'Kustom Perkenalan Diri (자기소개)',
              subtitle: 'Nama, pekerjaan, sekolah, asal & tujuan',
              isDark: isDark,
              badge: 'KUSTOM',
            ),
            _buildDrawerTile(
              index: 3,
              icon: Icons.fact_check_rounded,
              title: 'Hafalan Saya (Checklist Harian)',
              subtitle: 'Tandai & lacak kosa kata terhafal offline',
              isDark: isDark,
            ),
            _buildDrawerTile(
              index: 4,
              icon: Icons.school_rounded,
              title: 'Materi EPS-TOPIK (60 Bab)',
              subtitle: '7 level kurikulum dokumen resmi',
              isDark: isDark,
            ),
            _buildDrawerTile(
              index: 5,
              icon: Icons.military_tech_rounded,
              title: 'Latihan Ujian Bertingkat',
              subtitle: 'TOPIK Level 1-4 & pembahasan dwibahasa',
              isDark: isDark,
            ),

            const Divider(height: 24),

            // Quick Info & Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 20,
                    color: isDark ? AppTheme.accentCyan : AppTheme.primaryIndigo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      ),
                    ),
                  ),
                  if (widget.onThemeToggle != null)
                    Switch(
                      value: isDark,
                      activeThumbColor: AppTheme.primaryIndigo,
                      onChanged: (val) {
                        widget.onThemeToggle!(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Text(
                'Aplikasi berjalan 100% tanpa internet (SQLite lokal + TTS Native).',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '한국어',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Flexible(
              child: Text(
                'Korean Master',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Quick shortcut to Perkenalan Diri (Compact IconButton, zero overflow)
          IconButton(
            icon: const Icon(Icons.badge_outlined, size: 20, color: AppTheme.primaryIndigo),
            tooltip: 'Kustom Perkenalan Diri',
            visualDensity: VisualDensity.compact,
            onPressed: () => _navigateToTab(2),
          ),
          // Compact Offline Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentMint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: AppTheme.accentMint.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.offline_bolt_rounded, size: 11, color: AppTheme.accentMint),
                SizedBox(width: 2),
                Text(
                  'Offline',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentMint,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onThemeToggle != null) ...[
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 20,
              ),
              tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                widget.onThemeToggle!(newMode);
              },
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.translate_rounded),
            selectedIcon: Icon(Icons.translate_rounded, color: AppTheme.primaryIndigo),
            label: 'SOV',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppTheme.primaryIndigo),
            label: 'Kamus',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded, color: AppTheme.primaryIndigo),
            label: 'Kenal Diri',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded, color: AppTheme.primaryIndigo),
            label: 'Hafalan',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded, color: AppTheme.primaryIndigo),
            label: 'Materi',
          ),
          NavigationDestination(
            icon: Icon(Icons.military_tech_outlined),
            selectedIcon: Icon(Icons.military_tech_rounded, color: AppTheme.primaryIndigo),
            label: 'Ujian',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    String? badge,
  }) {
    final isSelected = _currentIndex == index;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryIndigo.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppTheme.primaryIndigo : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.primaryIndigo : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentCoral,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close Drawer
        _navigateToTab(index);
      },
    );
  }
}
