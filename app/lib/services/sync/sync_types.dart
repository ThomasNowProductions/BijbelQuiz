/// Represents an item in the sync queue
class SyncItem {
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? userId;
  final int retryCount;

  SyncItem({
    required this.key,
    required this.data,
    required this.timestamp,
    this.userId,
    this.retryCount = 0,
  });

  /// Creates a SyncItem from JSON
  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      key: json['key'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'retryCount': retryCount,
    };
  }

  /// Creates a copy with updated fields
  SyncItem copyWith({
    String? key,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? userId,
    int? retryCount,
  }) {
    return SyncItem(
      key: key ?? this.key,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Types of sync errors
enum SyncErrorType {
  network,
  auth,
  storage,
  validation,
  conflict,
  unknown,
}

/// Represents a sync error
class SyncError implements Exception {
  final SyncErrorType type;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  SyncError(
    this.type,
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'SyncError($type): $message';
}
