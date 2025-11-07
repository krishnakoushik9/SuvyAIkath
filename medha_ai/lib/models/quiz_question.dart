class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String difficulty;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] as String,
      options: (map['options'] as List).cast<String>(),
      correctAnswer: map['correctAnswer'] is int
          ? map['correctAnswer'] as int
          : int.tryParse(map['correctAnswer'].toString()) ?? 0,
      difficulty: map['difficulty'] as String? ?? 'basic',
      explanation: map['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'difficulty': difficulty,
        'explanation': explanation,
      };
}
