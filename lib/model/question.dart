class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'] as String? ?? '',
      options:
          (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswer: map['correctAnswer'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
    );
  }

  bool isValid() {
    return question.isNotEmpty &&
        options.length == 4 &&
        correctAnswer >= 0 &&
        correctAnswer < 4;
  }
}
