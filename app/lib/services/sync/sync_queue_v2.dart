import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../logger.dart';
import 'sync_types_v2.dart';

/// Reliable sync queue with exponential backoff and retry logic
class SyncQueue {
  static const String _queueKey = 'sync_queue_v2';
  static const String _deviceIdKey = 'sync_device_id';
  static const int _maxRetries = 5; // Max retries before giving up
  static const int _maxBackoffShift =
      8; // Max shift: 2^8 = 256 seconds (~4.3 minutes)

  final _uuid = const Uuid();
  final Map<String, SyncQueueItem> _items = {};
  final _controller = StreamController<SyncQueueItem>.broadcast();
  bool _isDisposed = false;
  String? _deviceId;
  final _deviceIdCompleter = Completer<String>();

  /// Stream of queue changes
  Stream<SyncQueueItem> get onQueueChange => _controller.stream;

  /// Get all pending items (haven't exceeded max retries)
  List<SyncQueueItem> get pendingItems =>
      _items.values.where((item) => item.retryCount < _maxRetries).toList();

  /// Get failed items (max retries exceeded)
  List<SyncQueueItem> get failedItems =>
      _items.values.where((item) => item.retryCount >= _maxRetries).toList();

  /// Initialize the queue
  Future<void> initialize() async {
    if (_isDisposed) throw StateError('SyncQueue has been disposed');
    await _loadQueue();
    await _ensureDeviceId();
  }

  /// Get or create device ID
  Future<String> get deviceId async {
    if (_isDisposed) throw StateError('SyncQueue has been disposed');
    if (_deviceId != null) return _deviceId!;
    if (_deviceIdCompleter.isCompleted) {
      return _deviceIdCompleter.future;
    }
    await _ensureDeviceId();
    return _deviceIdCompleter.future;
  }

  Future<void> _ensureDeviceId() async {
    if (_deviceId != null) {
      if (!_deviceIdCompleter.isCompleted) {
        _deviceIdCompleter.complete(_deviceId);
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var deviceId = prefs.getString(_deviceIdKey);

      if (deviceId == null) {
        deviceId = _uuid.v4();
        await prefs.setString(_deviceIdKey, deviceId);
      }

      _deviceId = deviceId;
      if (!_deviceIdCompleter.isCompleted) {
        _deviceIdCompleter.complete(deviceId);
      }
    } catch (e) {
      // Generate temporary ID if storage fails
      _deviceId = _uuid.v4();
      if (!_deviceIdCompleter.isCompleted) {
        _deviceIdCompleter.complete(_deviceId);
      }
    }
  }

  /// Add an item to the queue
  Future<void> enqueue({
    required String key,
    required Map<String, dynamic> data,
    int expectedVersion = 0,
    SyncItemPriority priority = SyncItemPriority.normal,
  }) async {
    if (_isDisposed) throw StateError('SyncQueue has been disposed');

    final id = _uuid.v4();
    final item = SyncQueueItem(
      id: id,
      key: key,
      data: data,
      expectedVersion: expectedVersion,
      createdAt: DateTime.now(),
      priority: priority,
    );

    _items[id] = item;
    await _saveQueue();
    _controller.add(item);
  }

  /// Remove an item from the queue
  Future<void> dequeue(String id) async {
    if (_isDisposed) return;
    _items.remove(id);
    await _saveQueue();
  }

  /// Update an item after a sync attempt
  Future<void> updateItem(SyncQueueItem item) async {
    if (_isDisposed) return;
    _items[item.id] = item;
    await _saveQueue();
    _controller.add(item);
  }

  /// Mark an item as successfully synced
  Future<void> markSuccess(String id, int newVersion) async {
    if (_isDisposed) return;
    _items.remove(id);
    await _saveQueue();
  }

  /// Mark an item as failed and increment retry count
  Future<void> markFailed(String id, String error) async {
    if (_isDisposed) return;
    final item = _items[id];
    if (item == null) return;

    final updated = item.copyWith(
      retryCount: item.retryCount + 1,
      lastAttemptAt: DateTime.now(),
      lastError: error,
    );

    _items[id] = updated;
    await _saveQueue();
    _controller.add(updated);
  }

  /// Get the next item ready for processing
  SyncQueueItem? getNextReadyItem() {
    if (_isDisposed) return null;
    final now = DateTime.now();

    // Sort by priority (high first) and then by creation time (oldest first)
    final sortedItems = _items.values.toList()
      ..sort((a, b) {
        final priorityComparison = b.priority.index.compareTo(a.priority.index);
        if (priorityComparison != 0) return priorityComparison;
        return a.createdAt.compareTo(b.createdAt);
      });

    for (final item in sortedItems) {
      // Skip items that have exceeded max retries
      if (item.retryCount >= _maxRetries) continue;

      // Check if item is ready for retry
      if (item.lastAttemptAt == null) return item;

      final backoffDuration = _calculateBackoff(item.retryCount);
      if (now.difference(item.lastAttemptAt!) >= backoffDuration) {
        return item;
      }
    }

    return null;
  }

  /// Calculate backoff delay with overflow protection
  Duration _calculateBackoff(int retryCount) {
    // Cap retry count to prevent integer overflow
    final cappedRetryCount = min(retryCount, _maxBackoffShift);
    final delaySeconds =
        1 << cappedRetryCount; // 1, 2, 4, 8, 16, 32, 64, 128, 256
    final maxDelaySeconds = 300; // 5 minutes max
    return Duration(
      seconds: delaySeconds > maxDelaySeconds ? maxDelaySeconds : delaySeconds,
    );
  }

  /// Check if there are items ready to process
  bool get hasReadyItems {
    if (_isDisposed) return false;
    return getNextReadyItem() != null;
  }

  /// Clear all items from the queue
  Future<void> clear() async {
    if (_isDisposed) return;
    _items.clear();
    await _saveQueue();
  }

  /// Clear only failed items (max retries exceeded)
  Future<void> clearFailed() async {
    if (_isDisposed) return;
    final failedIds = _items.values
        .where((item) => item.retryCount >= _maxRetries)
        .map((item) => item.id)
        .toList();

    for (final id in failedIds) {
      _items.remove(id);
    }

    await _saveQueue();
  }

  /// Load queue from persistent storage
  Future<void> _loadQueue() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);

      if (queueJson != null && queueJson.isNotEmpty) {
        final decoded = json.decode(queueJson);
        if (decoded is List) {
          _items.clear();

          for (final itemJson in decoded) {
            if (itemJson is Map<String, dynamic>) {
              try {
                final item = SyncQueueItem.fromJson(itemJson);
                _items[item.id] = item;
              } catch (e) {
                // Skip invalid items
                continue;
              }
            }
          }
        }
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load sync queue', e, stack);
      // Start with empty queue on error
      _items.clear();
    }
  }

  /// Save queue to persistent storage
  Future<void> _saveQueue() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsList = _items.values.map((e) => e.toJson()).toList();
      final queueJson = json.encode(itemsList);
      await prefs.setString(_queueKey, queueJson);
    } catch (e, stack) {
      AppLogger.error('Failed to save sync queue', e, stack);
    }
  }

  /// Get queue statistics
  Map<String, dynamic> getStats() {
    final pending = pendingItems.length;
    final failed = failedItems.length;
    final total = _items.length;

    return {
      'total': total,
      'pending': pending,
      'failed': failed,
      'ready': hasReadyItems,
    };
  }

  /// Dispose resources
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _controller.close();
    _items.clear();
  }
}
