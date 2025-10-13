import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/purchase.dart';
import '../services/logger.dart';

/// Service for managing purchases and store items
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  static const String _baseUrl = 'https://api.bijbelquiz.app';
  late final Dio _dio;

  /// Initialize the purchase service
  Future<void> initialize(String? accessToken) async {
    try {
      _dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      ));

      // Add request interceptor to include auth token
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            AppLogger.warning('Purchase service failed: Unauthorized');
          }
          handler.next(error);
        },
      ));

      AppLogger.info('PurchaseService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize PurchaseService', e);
      rethrow;
    }
  }

  /// Update access token
  void updateAccessToken(String? accessToken) {
    if (accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Get user's purchases
  Future<List<Purchase>?> getUserPurchases({
    String? status,
    String? itemType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (status != null) queryParams['status'] = status;
      if (itemType != null) queryParams['itemType'] = itemType;

      final response = await _dio.get('/api/purchases/me', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> purchasesData = response.data['purchases'];
        return purchasesData.map((purchase) => Purchase.fromJson(purchase)).toList();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user purchases', e);
      return null;
    }
  }

  /// Create a new purchase
  Future<Purchase?> createPurchase(StoreItem item) async {
    try {
      final response = await _dio.post('/api/purchases', data: {
        'itemType': item.type,
        'itemId': item.id,
        'itemName': item.name,
        'cost': item.cost,
        'metadata': item.metadata,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Purchase.fromJson(response.data['purchase']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to create purchase', e);
      return null;
    }
  }

  /// Get purchase by ID
  Future<Purchase?> getPurchase(String purchaseId) async {
    try {
      final response = await _dio.get('/api/purchases/$purchaseId');
      if (response.statusCode == 200) {
        return Purchase.fromJson(response.data['purchase']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get purchase', e);
      return null;
    }
  }

  /// Check if user owns an item
  Future<bool> checkItemOwnership(String itemType, String itemId) async {
    try {
      final response = await _dio.get('/api/purchases/check/$itemType/$itemId');
      if (response.statusCode == 200) {
        return response.data['owned'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to check item ownership', e);
      return false;
    }
  }

  /// Get available store items
  Future<List<StoreItem>?> getStoreItems({
    String? itemType,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      
      if (itemType != null) queryParams['itemType'] = itemType;

      final response = await _dio.get('/api/purchases/store/items', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> itemsData = response.data['items'];
        return itemsData.map((item) => StoreItem.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get store items', e);
      return null;
    }
  }

  /// Refund a purchase
  Future<bool> refundPurchase(String purchaseId) async {
    try {
      final response = await _dio.post('/api/purchases/$purchaseId/refund');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to refund purchase', e);
      return false;
    }
  }

  /// Get user's active powerups
  Future<List<Purchase>?> getActivePowerups() async {
    try {
      final purchases = await getUserPurchases(
        itemType: 'powerup',
        status: 'completed',
      );

      if (purchases == null) return null;

      // Filter for active (non-expired) powerups
      final now = DateTime.now();
      return purchases.where((purchase) {
        if (purchase.status != PurchaseStatus.completed) return false;
        if (purchase.expiresAt == null) return true; // Permanent powerup
        return now.isBefore(purchase.expiresAt!);
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to get active powerups', e);
      return null;
    }
  }

  /// Get user's purchased themes
  Future<List<Purchase>?> getPurchasedThemes() async {
    try {
      return await getUserPurchases(
        itemType: 'theme',
        status: 'completed',
      );
    } catch (e) {
      AppLogger.error('Failed to get purchased themes', e);
      return null;
    }
  }

  /// Get user's purchased features
  Future<List<Purchase>?> getPurchasedFeatures() async {
    try {
      return await getUserPurchases(
        itemType: 'feature',
        status: 'completed',
      );
    } catch (e) {
      AppLogger.error('Failed to get purchased features', e);
      return null;
    }
  }

  /// Check if user can afford an item
  Future<bool> canAffordItem(int cost, int currentScore) async {
    return currentScore >= cost;
  }

  /// Get purchase history with pagination
  Future<PurchaseHistory?> getPurchaseHistory({
    int page = 1,
    int limit = 20,
    String? itemType,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final purchases = await getUserPurchases(
        itemType: itemType,
        limit: limit,
        offset: offset,
      );

      if (purchases == null) return null;

      // Get total count (this would typically come from the API)
      final totalPurchases = await getUserPurchases(limit: 1000);
      final totalCount = totalPurchases?.length ?? 0;

      return PurchaseHistory(
        purchases: purchases,
        currentPage: page,
        totalPages: (totalCount / limit).ceil(),
        totalCount: totalCount,
        hasNextPage: offset + limit < totalCount,
        hasPreviousPage: page > 1,
      );
    } catch (e) {
      AppLogger.error('Failed to get purchase history', e);
      return null;
    }
  }
}

/// Represents paginated purchase history
class PurchaseHistory {
  final List<Purchase> purchases;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PurchaseHistory({
    required this.purchases,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}