import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../logger.dart';
import 'sync_types.dart';

class SyncQueue {
  static const String _storageKey = 'sync_offline_queue';
  static const int _maxQueueSize = 100;
  static const Duration _expirationDuration = Duration(days: 7);

  final SharedPreferences _prefs;

  SyncQueue(this._prefs);

  /// Adds an item to the queue
  Future<void> add(SyncItem item) async {
    try {
      final queue = await _loadQueue();
      
      // Enforce maximum queue size
      if (queue.length >= _maxQueueSize) {
        AppLogger.warning('Offline queue at maximum size ($_maxQueueSize), removing oldest item');
        queue.removeAt(0); // Remove oldest item
      }

      queue.add(item);
      await _saveQueue(queue);
      AppLogger.info('Added item to sync queue: ${item.key} (Queue size: ${queue.length})');
    } catch (e) {
      AppLogger.error('Failed to add item to sync queue', e);
      rethrow;
    }
  }

  /// Removes items from the queue
  Future<void> remove(List<SyncItem> itemsToRemove) async {
    try {
      final queue = await _loadQueue();
      
      // Remove items that match key and timestamp
      queue.removeWhere((item) => itemsToRemove.any((r) => 
        r.key == item.key && 
        r.timestamp == item.timestamp &&
        r.userId == item.userId
      ));

      await _saveQueue(queue);
    } catch (e) {
      AppLogger.error('Failed to remove items from sync queue', e);
    }
  }

  /// Gets all items in the queue
  Future<List<SyncItem>> getAll() async {
    return _loadQueue();
  }

  /// Gets items for a specific user
  Future<List<SyncItem>> getForUser(String userId) async {
    final queue = await _loadQueue();
    return queue.where((item) => item.userId == userId).toList();
  }

  /// Clears the entire queue
  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }

  /// Cleans up expired items
  Future<void> cleanupExpired() async {
    try {
      final queue = await _loadQueue();
      final now = DateTime.now();
      
      final originalSize = queue.length;
      queue.removeWhere((item) => now.difference(item.timestamp) > _expirationDuration);

      if (queue.length < originalSize) {
        AppLogger.info('Cleaned up ${originalSize - queue.length} expired queue items');
        await _saveQueue(queue);
      }
    } catch (e) {
      AppLogger.error('Failed to clean up expired queue items', e);
    }
  }

  Future<List<SyncItem>> _loadQueue() async {
    try {
      final jsonStr = _prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList
          .map((json) => SyncItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to load sync queue', e);
      return [];
    }
  }

  Future<void> _saveQueue(List<SyncItem> queue) async {
    try {
      final jsonList = queue.map((item) => item.toJson()).toList();
      await _prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      AppLogger.error('Failed to save sync queue', e);
      throw SyncError(SyncErrorType.storage, 'Failed to save sync queue', originalError: e);
    }
  }
}
