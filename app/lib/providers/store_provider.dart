import 'package:flutter/foundation.dart';
import '../models/store_item.dart';
import '../services/store_service.dart';
import '../utils/automatic_error_reporter.dart';

class StoreProvider with ChangeNotifier {
  List<StoreItem> _storeItems = [];
  bool _isLoading = false;
  String? _error;

  List<StoreItem> get storeItems => _storeItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Checks if any store item is currently discounted
  bool get hasActiveDiscount {
    return _storeItems.any((item) => item.isCurrentlyDiscounted);
  }

  Future<void> loadStoreItems() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final storeService = StoreService();
      _storeItems = await storeService.getStoreItems();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();

      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportNetworkError(
        message: 'Failed to load store items',
        url: 'store_items table',
        additionalInfo: {
          'error': e.toString(),
          'operation': 'load_store_items',
          'items_count': _storeItems.length,
        },
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
