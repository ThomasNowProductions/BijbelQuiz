import 'dart:convert';

/// Model representing an API key with associated metadata
class ApiKey {
  /// Unique identifier for the API key
  final String id;

  /// The actual API key value (should be stored securely)
  final String key;

  /// User-defined name for the API key
  final String name;

  /// Date when the API key was created
  final DateTime createdAt;

  /// Date when the API key was last used
  final DateTime? lastUsedAt;

  /// Whether the API key is currently active
  final bool isActive;

  /// Number of requests made with this key
  final int requestCount;

  ApiKey({
    required this.id,
    required this.key,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
    this.isActive = true,
    this.requestCount = 0,
  });

  /// Creates an ApiKey instance from a JSON map
  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? 'Unnamed API Key',
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      requestCount: json['requestCount'] ?? 0,
    );
  }

  /// Converts this ApiKey instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'isActive': isActive,
      'requestCount': requestCount,
    };
  }

  /// Generates a masked version of the API key for display purposes
  String get maskedKey {
    if (key.length < 8) {
      return '*' * key.length;
    }
    
    final start = key.substring(0, 4);
    final end = key.substring(key.length - 4);
    return '$start${'*' * (key.length - 8)}$end';
  }

  /// Creates a copy of this ApiKey with updated values
  ApiKey copyWith({
    String? id,
    String? key,
    String? name,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool? isActive,
    int? requestCount,
  }) {
    return ApiKey(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isActive: isActive ?? this.isActive,
      requestCount: requestCount ?? this.requestCount,
    );
  }

  @override
  String toString() {
    return 'ApiKey(id: $id, name: $name, createdAt: $createdAt, isActive: $isActive)';
  }
}