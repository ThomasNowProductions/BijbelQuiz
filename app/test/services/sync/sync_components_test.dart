import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijbelquiz/services/sync/sync_types.dart';
import 'package:bijbelquiz/services/sync/sync_queue.dart';
import 'package:bijbelquiz/services/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    test('GameStatsConflictResolver merges correctly', () {
      final resolver = GameStatsConflictResolver();
      final existing = {
        'score': 100,
        'currentStreak': 5,
        'longestStreak': 10,
        'incorrectAnswers': 2,
      };
      final incoming = {
        'score': 150,
        'currentStreak': 2,
        'longestStreak': 12,
        'incorrectAnswers': 1,
      };

      final merged = resolver.resolve(existing, incoming);

      expect(merged['score'], 150);
      expect(merged['currentStreak'], 5); // Max of 5 and 2
      expect(merged['longestStreak'], 12); // Max of 10 and 12
      expect(merged['incorrectAnswers'], 2); // Max of 2 and 1
    });

    test('SettingsConflictResolver merges AI themes', () {
      final resolver = SettingsConflictResolver();
      final existing = {
        'theme': 'dark',
        'aiThemes': {'theme1': 'data1'},
      };
      final incoming = {
        'theme': 'light',
        'aiThemes': {'theme2': 'data2'},
      };

      final merged = resolver.resolve(existing, incoming);

      expect(merged['theme'], 'light'); // Incoming wins
      expect(merged['aiThemes']['theme1'], 'data1'); // Preserved
      expect(merged['aiThemes']['theme2'], 'data2'); // Added
    });
  });

  group('SyncQueue', () {
    late SyncQueue queue;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      queue = SyncQueue(prefs);
    });

    test('adds and retrieves items', () async {
      final item = SyncItem(
        key: 'test_key',
        data: {'foo': 'bar'},
        timestamp: DateTime.now(),
        userId: 'user1',
      );

      await queue.add(item);
      final items = await queue.getAll();

      expect(items.length, 1);
      expect(items.first.key, 'test_key');
      expect(items.first.data['foo'], 'bar');
    });

    test('filters by user', () async {
      await queue.add(SyncItem(
        key: 'k1',
        data: {},
        timestamp: DateTime.now(),
        userId: 'user1',
      ));
      await queue.add(SyncItem(
        key: 'k2',
        data: {},
        timestamp: DateTime.now(),
        userId: 'user2',
      ));

      final user1Items = await queue.getForUser('user1');
      expect(user1Items.length, 1);
      expect(user1Items.first.userId, 'user1');
    });
  });
}
