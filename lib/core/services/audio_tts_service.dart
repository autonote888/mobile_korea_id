import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Offline Audio Engine wrapping Android system native Text-To-Speech.
/// Runs completely offline without cloud audio streaming.
class AudioTtsService extends ChangeNotifier {
  AudioTtsService._internal() {
    _initTts();
  }
  static final AudioTtsService instance = AudioTtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeaking = false;
  static const double normalSpeechRate = 0.45;
  static const double slowSpeechRate = 0.22; // Mode Kura-kura (Slow)

  String _currentText = '';
  double _speechRate = normalSpeechRate;
  bool _isSlowMode = false;
  final double _volume = 1.0;
  final double _pitch = 1.0;
  String _currentLanguage = 'ko-KR';

  bool get isSpeaking => _isSpeaking;
  bool get isSlowMode => _isSlowMode;
  String get currentText => _currentText;
  double get speechRate => _speechRate;

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isSlowMode = false;
        _currentText = '';
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _isSlowMode = false;
        _currentText = '';
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        if (kDebugMode) print('[AudioTtsService] TTS error: $msg');
        _isSpeaking = false;
        _isSlowMode = false;
        _currentText = '';
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) print('[AudioTtsService] TTS init error: $e');
    }
  }

  /// Speaks Korean text offline using device TTS engine at normal speed.
  Future<void> speakKorean(String text) async {
    if (text.trim().isEmpty) return;
    try {
      if (_isSpeaking && _currentText == text && !_isSlowMode) {
        await stop();
        return;
      }
      await stop();
      _isSlowMode = false;
      _currentLanguage = 'ko-KR';
      await _flutterTts.setLanguage('ko-KR');
      await _flutterTts.setSpeechRate(normalSpeechRate);
      _currentText = text;
      _isSpeaking = true;
      notifyListeners();
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) print('[AudioTtsService] Error speaking Korean: $e');
      _isSpeaking = false;
      _isSlowMode = false;
      notifyListeners();
    }
  }

  /// Speaks Korean text in slow mode (Mode Kura-kura) at reduced speed.
  Future<void> speakKoreanSlow(String text) async {
    if (text.trim().isEmpty) return;
    try {
      if (_isSpeaking && _currentText == text && _isSlowMode) {
        await stop();
        return;
      }
      await stop();
      _isSlowMode = true;
      _currentLanguage = 'ko-KR';
      await _flutterTts.setLanguage('ko-KR');
      await _flutterTts.setSpeechRate(slowSpeechRate);
      _currentText = text;
      _isSpeaking = true;
      notifyListeners();
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) print('[AudioTtsService] Error speaking Korean slow: $e');
      _isSpeaking = false;
      _isSlowMode = false;
      notifyListeners();
    }
  }

  /// Speaks English text offline using device TTS engine.
  Future<void> speakEnglish(String text) async {
    if (text.trim().isEmpty) return;
    try {
      if (_isSpeaking && _currentText == text) {
        await stop();
        return;
      }
      await stop();
      _currentLanguage = 'en-US';
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      _currentText = text;
      _isSpeaking = true;
      notifyListeners();
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) print('[AudioTtsService] Error speaking English: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Adjust speech rate (default 0.45 for learners).
  Future<void> setRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  /// Stops current speech playback.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      if (kDebugMode) print('[AudioTtsService] Stop error: $e');
    }
    _isSpeaking = false;
    _currentText = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
