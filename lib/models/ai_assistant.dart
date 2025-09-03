class AIQuestion {
  final String id;
  final String question;
  final String? answer;
  final DateTime timestamp;
  final bool isAnswered;
  final String category;

  AIQuestion({
    required this.id,
    required this.question,
    this.answer,
    required this.timestamp,
    this.isAnswered = false,
    this.category = 'spiritual',
  });

  AIQuestion copyWith({
    String? id,
    String? question,
    String? answer,
    DateTime? timestamp,
    bool? isAnswered,
    String? category,
  }) {
    return AIQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      timestamp: timestamp ?? this.timestamp,
      isAnswered: isAnswered ?? this.isAnswered,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
      'isAnswered': isAnswered,
      'category': category,
    };
  }

  factory AIQuestion.fromJson(Map<String, dynamic> json) {
    return AIQuestion(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      timestamp: DateTime.parse(json['timestamp']),
      isAnswered: json['isAnswered'] ?? false,
      category: json['category'] ?? 'spiritual',
    );
  }
}

class SpiritualGuidance {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> keywords;
  final String? reference;

  SpiritualGuidance({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.keywords,
    this.reference,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'keywords': keywords,
      'reference': reference,
    };
  }

  factory SpiritualGuidance.fromJson(Map<String, dynamic> json) {
    return SpiritualGuidance(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      keywords: List<String>.from(json['keywords']),
      reference: json['reference'],
    );
  }
}
