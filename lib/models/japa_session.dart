class JapaSession {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final int targetRounds;
  final int completedRounds;
  final int currentBead;
  final bool isActive;
  final bool isPaused;
  final List<JapaRound> rounds;
  final String? notes;

  JapaSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.targetRounds,
    this.completedRounds = 0,
    this.currentBead = 0,
    this.isActive = true,
    this.isPaused = false,
    this.rounds = const [],
    this.notes,
  });

  JapaSession copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? targetRounds,
    int? completedRounds,
    int? currentBead,
    bool? isActive,
    bool? isPaused,
    List<JapaRound>? rounds,
    String? notes,
  }) {
    return JapaSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      targetRounds: targetRounds ?? this.targetRounds,
      completedRounds: completedRounds ?? this.completedRounds,
      currentBead: currentBead ?? this.currentBead,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      rounds: rounds ?? this.rounds,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetRounds': targetRounds,
      'completedRounds': completedRounds,
      'currentBead': currentBead,
      'isActive': isActive,
      'isPaused': isPaused,
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'notes': notes,
    };
  }

  factory JapaSession.fromJson(Map<String, dynamic> json) {
    return JapaSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      targetRounds: json['targetRounds'],
      completedRounds: json['completedRounds'] ?? 0,
      currentBead: json['currentBead'] ?? 0,
      isActive: json['isActive'] ?? true,
      isPaused: json['isPaused'] ?? false,
      rounds:
          (json['rounds'] as List?)
              ?.map((r) => JapaRound.fromJson(r))
              .toList() ??
          [],
      notes: json['notes'],
    );
  }
}

class JapaRound {
  final int roundNumber;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final bool isCompleted;

  JapaRound({
    required this.roundNumber,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.isCompleted = false,
  });

  JapaRound copyWith({
    int? roundNumber,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    bool? isCompleted,
  }) {
    return JapaRound(
      roundNumber: roundNumber ?? this.roundNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'isCompleted': isCompleted,
    };
  }

  factory JapaRound.fromJson(Map<String, dynamic> json) {
    return JapaRound(
      roundNumber: json['roundNumber'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationSeconds: json['durationSeconds'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
