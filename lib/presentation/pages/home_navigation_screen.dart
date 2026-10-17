import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import 'tab_translator_grammar.dart';
import 'tab_dictionary.dart';
import 'tab_exam_levels.dart';

/// Main Root Navigation Screen wrapping Material 3 NavigationBar.
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

  final List<Widget> _pages = const [
    TabTranslatorGrammar(),
    TabDictionary(),
    TabExamLevels(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '한국어',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Korean Master',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          // Offline Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentMint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: AppTheme.accentMint.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.offline_bolt_rounded, size: 13, color: AppTheme.accentMint),
                SizedBox(width: 4),
                Text(
                  '100% Offline',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentMint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Theme Toggle Button
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 20,
              ),
              tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
              onPressed: () {
                final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                widget.onThemeToggle!(newMode);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.translate_rounded),
            selectedIcon: Icon(Icons.translate_rounded, color: AppTheme.primaryIndigo),
            label: 'Parser SOV',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppTheme.primaryIndigo),
            label: 'Kamus Trilingual',
          ),
          NavigationDestination(
            icon: Icon(Icons.military_tech_rounded),
            selectedIcon: Icon(Icons.military_tech_rounded, color: AppTheme.primaryIndigo),
            label: 'Latihan Ujian',
          ),
        ],
      ),
    );
  }
}
