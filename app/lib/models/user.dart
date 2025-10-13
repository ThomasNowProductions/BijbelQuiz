import 'package:uuid/uuid.dart';

/// Represents a user in the BijbelQuiz app
class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.lastSeen,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen'] as String) 
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, username: $username, displayName: $displayName)';
  }
}

/// Represents user statistics
class UserStats {
  final String id;
  final String userId;
  final int score;
  final int currentStreak;
  final int longestStreak;
  final int incorrectAnswers;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int totalTimeSpent; // in seconds
  final int level;
  final int experiencePoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStats({
    required this.id,
    required this.userId,
    this.score = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.incorrectAnswers = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.totalTimeSpent = 0,
    this.level = 1,
    this.experiencePoints = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      score: json['score'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
      totalQuestionsAnswered: json['total_questions_answered'] as int? ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] as int? ?? 0,
      totalTimeSpent: json['total_time_spent'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experience_points'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'score': score,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'incorrect_answers': incorrectAnswers,
      'total_questions_answered': totalQuestionsAnswered,
      'total_correct_answers': totalCorrectAnswers,
      'total_time_spent': totalTimeSpent,
      'level': level,
      'experience_points': experiencePoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserStats copyWith({
    String? id,
    String? userId,
    int? score,
    int? currentStreak,
    int? longestStreak,
    int? incorrectAnswers,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    int? totalTimeSpent,
    int? level,
    int? experiencePoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate accuracy percentage
  double get accuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }

  /// Calculate average time per question
  double get averageTimePerQuestion {
    if (totalQuestionsAnswered == 0) return 0.0;
    return totalTimeSpent / totalQuestionsAnswered;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserStats(id: $id, userId: $userId, score: $score, level: $level)';
  }
}