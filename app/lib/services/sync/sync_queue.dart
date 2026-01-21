import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_types.dart';

class SyncQueue {
  static const String _storageKey = 'sync_queue';
  final SharedPreferences _prefs;

  SyncQueue(this._prefs);

  Future<void> add(SyncItem item) async {
    final items = await getAll();
    items.add(item);
    await _saveItems(items);
  }

  Future<List<SyncItem>> getAll() async {
    final jsonList = _prefs.getStringList(_storageKey) ?? [];
    return jsonList
        .map((jsonStr) =>
            SyncItem.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  Future<List<SyncItem>> getForUser(String userId) async {
    final allItems = await getAll();
    return allItems.where((item) => item.userId == userId).toList();
  }

  Future<void> _saveItems(List<SyncItem> items) async {
    final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }
}
