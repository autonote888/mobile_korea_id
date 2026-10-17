import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/exam_model.dart';
import '../widgets/tts_speaker_button.dart';

/// Interactive Exam Quiz Screen featuring instant visual feedback,
/// bilingual explanations, TTS audio prompt, and local result persistence.
class QuizScreen extends StatefulWidget {
  final ExamPackage package;

  const QuizScreen({super.key, required this.package});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<ExamQuestion> _questions = [];
  bool _isLoading = true;

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption; // 'A', 'B', 'C', 'D'
  bool _hasAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await DatabaseHelper.instance.getQuestionsForPackage(widget.package.id);
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  void _handleOptionSelect(String optionLetter) {
    if (_hasAnswered) return;

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = optionLetter.toUpperCase() == currentQuestion.correctAnswer.toUpperCase();

    setState(() {
      _selectedOption = optionLetter;
      _hasAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final total = _questions.length;
    final percentage = total > 0 ? (_score / total) * 100 : 0.0;

    // Persist result offline in SQLite
    final history = UserQuizHistory(
      packageId: widget.package.id,
      score: _score,
      totalQuestions: total,
      percentage: percentage,
      completedAt: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.saveQuizResult(history);

    if (!mounted) return;

    // Show comprehensive results dialog
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Center(
            child: Text(
              percentage >= 80
                  ? '축하합니다! (Luar Biasa!)'
                  : (percentage >= 60 ? 'Bagus! Terus Latihan!' : 'Jangan Menyerah!'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: percentage >= 60 ? AppTheme.accentMint : AppTheme.accentCoral,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (percentage >= 60 ? AppTheme.accentMint : AppTheme.accentCoral).withValues(alpha: 0.12),
                  border: Border.all(
                    color: (percentage >= 60 ? AppTheme.accentMint : AppTheme.accentCoral),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: percentage >= 60 ? AppTheme.accentMint : AppTheme.accentCoral,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Skor Anda: $_score dari $total soal benar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paket: ${widget.package.title}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _currentIndex = 0;
                  _score = 0;
                  _selectedOption = null;
                  _hasAnswered = false;
                });
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ulangi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true); // Return to level list with refresh flag
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.package.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.package.title)),
        body: const Center(child: Text('Tidak ada soal dalam paket ini.')),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.package.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          // Live Score Pill
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentMint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: AppTheme.accentMint.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accentMint),
                const SizedBox(width: 4),
                Text(
                  'Skor: $_score',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentMint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              color: AppTheme.primaryIndigo,
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Counter & Type Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Soal ${_currentIndex + 1} dari ${_questions.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            question.type.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryIndigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Question Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                            ),
                          ),
                          if (question.hangulAudioText.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      question.hangulAudioText,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.primaryDarkIndigo,
                                      ),
                                    ),
                                  ),
                                  TtsSpeakerButton(
                                    text: question.hangulAudioText,
                                    size: 18,
                                    activeColor: AppTheme.primaryIndigo,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Options: A, B, C, D
                    _buildOptionButton('A', question.optionA, question.correctAnswer, isDark),
                    const SizedBox(height: 10),
                    _buildOptionButton('B', question.optionB, question.correctAnswer, isDark),
                    const SizedBox(height: 10),
                    _buildOptionButton('C', question.optionC, question.correctAnswer, isDark),
                    const SizedBox(height: 10),
                    _buildOptionButton('D', question.optionD, question.correctAnswer, isDark),

                    // Bilingual Explanation Card (Shown after answering)
                    if (_hasAnswered) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedOption == question.correctAnswer
                                ? AppTheme.accentMint.withValues(alpha: 0.5)
                                : AppTheme.accentCoral.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedOption == question.correctAnswer
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: _selectedOption == question.correctAnswer
                                      ? AppTheme.accentMint
                                      : AppTheme.accentCoral,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedOption == question.correctAnswer
                                      ? 'Jawaban Benar!'
                                      : 'Jawaban Kurang Tepat (Kunci: ${question.correctAnswer})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedOption == question.correctAnswer
                                        ? AppTheme.accentMint
                                        : AppTheme.accentCoral,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Text(
                              '🇮🇩 Penjelasan:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              question.explanationId,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🇬🇧 Explanation:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              question.explanationEn,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryIndigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentIndex < _questions.length - 1 ? 'Soal Berikutnya ➔' : 'Lihat Hasil Ujian',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    String letter,
    String optionText,
    String correctAnswer,
    bool isDark,
  ) {
    final isSelected = _selectedOption == letter;
    final isCorrectAnswer = letter.toUpperCase() == correctAnswer.toUpperCase();

    Color bgColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    Color borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    Color letterColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    Color textColor = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;

    if (_hasAnswered) {
      if (isCorrectAnswer) {
        // Correct answer highlighted in soft green
        bgColor = AppTheme.accentMint.withValues(alpha: isDark ? 0.2 : 0.1);
        borderColor = AppTheme.accentMint;
        letterColor = AppTheme.accentMint;
        textColor = isDark ? Colors.white : const Color(0xFF065F46);
      } else if (isSelected && !isCorrectAnswer) {
        // Wrong selected option in soft red
        bgColor = AppTheme.accentCoral.withValues(alpha: isDark ? 0.2 : 0.1);
        borderColor = AppTheme.accentCoral;
        letterColor = AppTheme.accentCoral;
        textColor = isDark ? Colors.white : const Color(0xFF991B1B);
      }
    } else if (isSelected) {
      bgColor = AppTheme.primaryIndigo.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryIndigo;
      letterColor = AppTheme.primaryIndigo;
    }

    return InkWell(
      onTap: () => _handleOptionSelect(letter),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: borderColor, width: isSelected || (_hasAnswered && isCorrectAnswer) ? 2.0 : 1.0),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: letterColor.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: letterColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected || (_hasAnswered && isCorrectAnswer) ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (_hasAnswered && isCorrectAnswer)
              const Icon(Icons.check_circle_rounded, color: AppTheme.accentMint, size: 20),
            if (_hasAnswered && isSelected && !isCorrectAnswer)
              const Icon(Icons.cancel_rounded, color: AppTheme.accentCoral, size: 20),
          ],
        ),
      ),
    );
  }
}
