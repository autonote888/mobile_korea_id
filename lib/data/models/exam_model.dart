class ExamPackage {
  final int id;
  final String title;
  final int level;
  final int totalQuestions;
  final int? bestScore;
  final double? bestPercentage;

  const ExamPackage({
    required this.id,
    required this.title,
    required this.level,
    required this.totalQuestions,
    this.bestScore,
    this.bestPercentage,
  });

  factory ExamPackage.fromMap(Map<String, dynamic> map, {int? bestScore, double? bestPercentage}) {
    return ExamPackage(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      level: map['level'] as int? ?? 1,
      totalQuestions: map['total_questions'] as int? ?? 0,
      bestScore: bestScore,
      bestPercentage: bestPercentage,
    );
  }

  ExamPackage copyWith({
    int? bestScore,
    double? bestPercentage,
  }) {
    return ExamPackage(
      id: id,
      title: title,
      level: level,
      totalQuestions: totalQuestions,
      bestScore: bestScore ?? this.bestScore,
      bestPercentage: bestPercentage ?? this.bestPercentage,
    );
  }
}

class ExamQuestion {
  final int id;
  final int packageId;
  final String type;
  final String question;
  final String hangulAudioText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer; // 'A', 'B', 'C', 'D'
  final String explanationId;
  final String explanationEn;

  const ExamQuestion({
    required this.id,
    required this.packageId,
    required this.type,
    required this.question,
    required this.hangulAudioText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanationId,
    required this.explanationEn,
  });

  factory ExamQuestion.fromMap(Map<String, dynamic> map) {
    return ExamQuestion(
      id: map['id'] as int,
      packageId: map['package_id'] as int,
      type: map['type'] as String? ?? 'general',
      question: map['question'] as String? ?? '',
      hangulAudioText: map['hangul_audio_text'] as String? ?? '',
      optionA: map['option_a'] as String? ?? '',
      optionB: map['option_b'] as String? ?? '',
      optionC: map['option_c'] as String? ?? '',
      optionD: map['option_d'] as String? ?? '',
      correctAnswer: map['correct_answer'] as String? ?? 'A',
      explanationId: map['explanation_id'] as String? ?? '',
      explanationEn: map['explanation_en'] as String? ?? '',
    );
  }

  String getOptionByLetter(String letter) {
    switch (letter.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return '';
    }
  }
}

class UserQuizHistory {
  final int? id;
  final int packageId;
  final int score;
  final int totalQuestions;
  final double percentage;
  final String completedAt;

  const UserQuizHistory({
    this.id,
    required this.packageId,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.completedAt,
  });

  factory UserQuizHistory.fromMap(Map<String, dynamic> map) {
    return UserQuizHistory(
      id: map['id'] as int?,
      packageId: map['package_id'] as int,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
      percentage: (map['percentage'] as num).toDouble(),
      completedAt: map['completed_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'package_id': packageId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': percentage,
      'completed_at': completedAt,
    };
  }
}
