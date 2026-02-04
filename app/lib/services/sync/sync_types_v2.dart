/// Represents the state of a sync operation
enum SyncOperationState {
  /// No operation in progress
  idle,

  /// Data is being prepared for sync
  preparing,

  /// Sync is in progress
  syncing,

  /// Sync completed successfully
  completed,

  /// Sync failed but will be retried
  failedRetryable,

  /// Sync failed permanently (max retries exceeded or invalid data)
  failedPermanent,

  /// Sync is queued for later (offline)
  queued,
}

/// Represents a single data key's sync state
class DataKeySyncState {
  final String key;
  final SyncOperationState state;
  final int version;
  final DateTime? lastSyncAt;
  final DateTime? lastModifiedAt;
  final String? errorMessage;
  final int retryCount;

  DataKeySyncState({
    required this.key,
    this.state = SyncOperationState.idle,
    this.version = 0,
    this.lastSyncAt,
    this.lastModifiedAt,
    this.errorMessage,
    this.retryCount = 0,
  });

  DataKeySyncState copyWith({
    SyncOperationState? state,
    int? version,
    DateTime? lastSyncAt,
    DateTime? lastModifiedAt,
    String? errorMessage,
    int? retryCount,
  }) {
    return DataKeySyncState(
      key: key,
      state: state ?? this.state,
      version: version ?? this.version,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'state': state.name,
      'version': version,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'retryCount': retryCount,
    };
  }

  factory DataKeySyncState.fromJson(Map<String, dynamic> json) {
    return DataKeySyncState(
      key: json['key'] as String? ?? '',
      state: _parseSyncState(json['state']),
      version: json['version'] as int? ?? 0,
      lastSyncAt: _parseDateTime(json['lastSyncAt']),
      lastModifiedAt: _parseDateTime(json['lastModifiedAt']),
      errorMessage: json['errorMessage'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  static SyncOperationState _parseSyncState(dynamic value) {
    if (value is! String) return SyncOperationState.idle;
    return SyncOperationState.values.asNameMap()[value] ??
        SyncOperationState.idle;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
}

/// Represents a sync item in the queue
class SyncQueueItem {
  final String id;
  final String key;
  final Map<String, dynamic> data;
  final int expectedVersion;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final String? lastError;
  final SyncItemPriority priority;

  SyncQueueItem({
    required this.id,
    required this.key,
    required this.data,
    this.expectedVersion = 0,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptAt,
    this.lastError,
    this.priority = SyncItemPriority.normal,
  });

  Duration get backoffDelay {
    // Exponential backoff: 2^retryCount seconds, max 5 minutes
    final delaySeconds =
        1 << retryCount; // 1, 2, 4, 8, 16, 32, 64, 128, 256, 512...
    final maxDelaySeconds = 300; // 5 minutes max
    return Duration(
        seconds:
            delaySeconds > maxDelaySeconds ? maxDelaySeconds : delaySeconds);
  }

  bool get canRetry => retryCount < 5;

  bool get isReadyForRetry {
    if (lastAttemptAt == null) return true;
    return DateTime.now().difference(lastAttemptAt!) >= backoffDelay;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'data': data,
      'expectedVersion': expectedVersion,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'lastError': lastError,
      'priority': priority.name,
    };
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      data: (json['data'] is Map)
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
      expectedVersion: json['expectedVersion'] as int? ?? 0,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      retryCount: json['retryCount'] as int? ?? 0,
      lastAttemptAt: _parseDateTime(json['lastAttemptAt']),
      lastError: json['lastError'] as String?,
      priority: _parsePriority(json['priority']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  static SyncItemPriority _parsePriority(dynamic value) {
    if (value is! String) return SyncItemPriority.normal;
    return SyncItemPriority.values.asNameMap()[value] ??
        SyncItemPriority.normal;
  }

  SyncQueueItem copyWith({
    int? retryCount,
    DateTime? lastAttemptAt,
    String? lastError,
  }) {
    return SyncQueueItem(
      id: id,
      key: key,
      data: data,
      expectedVersion: expectedVersion,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      priority: priority,
    );
  }
}

/// Priority for sync queue items
enum SyncItemPriority {
  low,
  normal,
  high,
  critical,
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final int newVersion;
  final bool hadConflict;
  final Map<String, dynamic>? data;
  final String? error;
  final String action;

  SyncResult({
    required this.success,
    this.newVersion = 0,
    this.hadConflict = false,
    this.data,
    this.error,
    required this.action,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      success: json['success'] == true,
      newVersion: json['version'] as int? ?? 0,
      hadConflict: json['conflict'] == true,
      data: (json['data'] is Map)
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      error: json['error'] as String?,
      action: json['action'] as String? ?? 'unknown',
    );
  }

  @override
  String toString() {
    return 'SyncResult(success: $success, action: $action, version: $newVersion, conflict: $hadConflict${error != null ? ', error: $error' : ''})';
  }
}

/// Device sync metadata
class DeviceSyncMetadata {
  final String deviceId;
  final DateTime lastSyncAt;
  final int lastSyncVersion;
  final Map<String, dynamic> deviceInfo;

  DeviceSyncMetadata({
    required this.deviceId,
    required this.lastSyncAt,
    required this.lastSyncVersion,
    this.deviceInfo = const {},
  });

  factory DeviceSyncMetadata.fromJson(Map<String, dynamic> json) {
    return DeviceSyncMetadata(
      deviceId: json['device_id'] as String? ?? '',
      lastSyncAt: _parseDateTime(json['last_sync_at']) ?? DateTime.now(),
      lastSyncVersion: json['last_sync_version'] as int? ?? 0,
      deviceInfo: (json['device_info'] is Map)
          ? Map<String, dynamic>.from(json['device_info'] as Map)
          : {},
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
}

/// Sync data from server
class SyncDataEntry {
  final String key;
  final Map<String, dynamic> data;
  final int version;
  final String? deviceId;
  final DateTime modifiedAt;

  SyncDataEntry({
    required this.key,
    required this.data,
    required this.version,
    this.deviceId,
    required this.modifiedAt,
  });

  factory SyncDataEntry.fromJson(Map<String, dynamic> json) {
    return SyncDataEntry(
      key: json['data_key'] as String? ?? '',
      data: (json['data'] is Map)
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
      version: json['version'] as int? ?? 0,
      deviceId: json['device_id'] as String?,
      modifiedAt: _parseDateTime(json['modified_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
}

/// Configuration for sync behavior
class SyncConfig {
  /// Maximum number of retries for failed syncs
  final int maxRetries;

  /// Initial delay for exponential backoff (in seconds)
  final int initialBackoffSeconds;

  /// Maximum delay between retries (in seconds)
  final int maxBackoffSeconds;

  /// Whether to automatically sync on data changes
  final bool autoSync;

  /// Debounce duration for auto-sync (to batch rapid changes)
  final Duration debounceDuration;

  /// Whether to enable real-time updates
  final bool enableRealtime;

  const SyncConfig({
    this.maxRetries = 5,
    this.initialBackoffSeconds = 1,
    this.maxBackoffSeconds = 300,
    this.autoSync = true,
    this.debounceDuration = const Duration(seconds: 2),
    this.enableRealtime = true,
  });

  static const defaultConfig = SyncConfig();
}

/// Error types for sync operations
enum SyncErrorType {
  /// Network-related error (can retry)
  network,

  /// Authentication error (need to re-auth)
  auth,

  /// Data validation error (don't retry)
  validation,

  /// Server error (can retry)
  server,

  /// Conflict error (resolved by server)
  conflict,

  /// Unknown error
  unknown,
}

/// Sync error with type information
class SyncError {
  final SyncErrorType type;
  final String message;
  final String? details;
  final DateTime timestamp;

  SyncError({
    required this.type,
    required this.message,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isRetryable =>
      type == SyncErrorType.network ||
      type == SyncErrorType.server ||
      type == SyncErrorType.conflict;

  @override
  String toString() =>
      'SyncError($type: $message${details != null ? ' - $details' : ''})';
}
