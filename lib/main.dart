import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_theme.dart';
import 'data/database/database_helper.dart';
import 'presentation/pages/home_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation for optimal Korean study layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-initialize local offline database
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('[Main] Database pre-init notice: $e');
  }

  runApp(const TrilingualKoreanApp());
}

class TrilingualKoreanApp extends StatefulWidget {
  const TrilingualKoreanApp({super.key});

  @override
  State<TrilingualKoreanApp> createState() => _TrilingualKoreanAppState();
}

class _TrilingualKoreanAppState extends State<TrilingualKoreanApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _handleThemeToggle(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trilingual Korean Offline Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeNavigationScreen(
        currentThemeMode: _themeMode,
        onThemeToggle: _handleThemeToggle,
      ),
    );
  }
}
