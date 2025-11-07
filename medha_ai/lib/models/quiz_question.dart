class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String difficulty;
  final String explanation;
  final int? selectedAnswer;
  final bool isAnswered;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    required this.explanation,
    this.selectedAnswer,
    this.isAnswered = false,
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
      selectedAnswer: null,
      isAnswered: false,
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'difficulty': difficulty,
        'explanation': explanation,
      };

  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? difficulty,
    String? explanation,
    int? selectedAnswer,
    bool? isAnswered,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      difficulty: difficulty ?? this.difficulty,
      explanation: explanation ?? this.explanation,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }
}
