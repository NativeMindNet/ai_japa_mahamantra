import 'package:json_annotation/json_annotation.dart';

part 'ai_assistant.g.dart';

@JsonSerializable()
class AIConversation {
  final String question;
  final String answer;
  final DateTime timestamp;
  final String category;
  final String? sessionId;
  final Map<String, dynamic>? metadata;

  AIConversation({
    required this.question,
    required this.answer,
    required this.timestamp,
    required this.category,
    this.sessionId,
    this.metadata,
  });

  factory AIConversation.fromJson(Map<String, dynamic> json) =>
      _$AIConversationFromJson(json);

  Map<String, dynamic> toJson() => _$AIConversationToJson(this);

  AIConversation copyWith({
    String? question,
    String? answer,
    DateTime? timestamp,
    String? category,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    return AIConversation(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class AIQuestion {
  final String text;
  final String category;
  final DateTime timestamp;
  final bool isAnswered;
  final String? answerId;

  AIQuestion({
    required this.text,
    required this.category,
    required this.timestamp,
    this.isAnswered = false,
    this.answerId,
  });

  factory AIQuestion.fromJson(Map<String, dynamic> json) =>
      _$AIQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$AIQuestionToJson(this);

  AIQuestion copyWith({
    String? text,
    String? category,
    DateTime? timestamp,
    bool? isAnswered,
    String? answerId,
  }) {
    return AIQuestion(
      text: text ?? this.text,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isAnswered: isAnswered ?? this.isAnswered,
      answerId: answerId ?? this.answerId,
    );
  }
}

@JsonSerializable()
class AIAnswer {
  final String id;
  final String questionId;
  final String text;
  final DateTime timestamp;
  final String source; // 'mozgach:latest', 'local', 'fallback'
  final double confidence;
  final Map<String, dynamic>? metadata;

  AIAnswer({
    required this.id,
    required this.questionId,
    required this.text,
    required this.timestamp,
    required this.source,
    this.confidence = 1.0,
    this.metadata,
  });

  factory AIAnswer.fromJson(Map<String, dynamic> json) =>
      _$AIAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AIAnswerToJson(this);

  AIAnswer copyWith({
    String? id,
    String? questionId,
    String? text,
    DateTime? timestamp,
    String? source,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return AIAnswer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class AISession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> questionIds;
  final String? userId;
  final Map<String, dynamic>? context;

  AISession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.questionIds = const [],
    this.userId,
    this.context,
  });

  factory AISession.fromJson(Map<String, dynamic> json) =>
      _$AISessionFromJson(json);

  Map<String, dynamic> toJson() => _$AISessionToJson(this);

  AISession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? questionIds,
    String? userId,
    Map<String, dynamic>? context,
  }) {
    return AISession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      questionIds: questionIds ?? this.questionIds,
      userId: userId ?? this.userId,
      context: context ?? this.context,
    );
  }
}

@JsonSerializable()
class AIUsageStats {
  final int totalQuestions;
  final int successfulResponses;
  final int localResponses;
  final int fallbackResponses;
  final double successRate;
  final int cacheSize;
  final DateTime lastUpdated;

  AIUsageStats({
    required this.totalQuestions,
    required this.successfulResponses,
    required this.localResponses,
    required this.fallbackResponses,
    required this.successRate,
    required this.cacheSize,
    required this.lastUpdated,
  });

  factory AIUsageStats.fromJson(Map<String, dynamic> json) =>
      _$AIUsageStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AIUsageStatsToJson(this);

  AIUsageStats copyWith({
    int? totalQuestions,
    int? successfulResponses,
    int? localResponses,
    int? fallbackResponses,
    double? successRate,
    int? cacheSize,
    DateTime? lastUpdated,
  }) {
    return AIUsageStats(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      successfulResponses: successfulResponses ?? this.successfulResponses,
      localResponses: localResponses ?? this.localResponses,
      fallbackResponses: fallbackResponses ?? this.fallbackResponses,
      successRate: successRate ?? this.successRate,
      cacheSize: cacheSize ?? this.cacheSize,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
