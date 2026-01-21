class StoreItem {
  final String itemKey;
  final String itemName;
  final String itemDescription;
  final String itemType;
  final String? icon;
  final int basePrice;
  final int currentPrice;
  final bool isDiscounted;
  final int discountPercentage;
  final bool isActive;
  final String? category;
  final DateTime? discountStart;
  final DateTime? discountEnd;

  StoreItem({
    required this.itemKey,
    required this.itemName,
    required this.itemDescription,
    required this.itemType,
    this.icon,
    required this.basePrice,
    required this.currentPrice,
    required this.isDiscounted,
    required this.discountPercentage,
    required this.isActive,
    this.category,
    this.discountStart,
    this.discountEnd,
  }) {
    // Input validation
    _validateItemKey(itemKey);
    _validateItemName(itemName);
    _validateItemDescription(itemDescription);
    _validateItemType(itemType);
    _validatePrices(basePrice, currentPrice);
    _validateDiscountPercentage(discountPercentage);
    _validateIcon(icon);
    _validateCategory(category);
    _validateDiscountDates(discountStart, discountEnd);
  }

  static void _validateItemKey(String itemKey) {
    if (itemKey.isEmpty || itemKey.length > 50) {
      throw ArgumentError(
          'itemKey must be non-empty and less than 50 characters');
    }
  }

  static void _validateItemName(String itemName) {
    if (itemName.isEmpty || itemName.length > 100) {
      throw ArgumentError(
          'itemName must be non-empty and less than 100 characters');
    }
  }

  static void _validateItemDescription(String itemDescription) {
    if (itemDescription.length > 500) {
      throw ArgumentError('itemDescription must be less than 500 characters');
    }
  }

  static void _validateItemType(String itemType) {
    if (!['powerup', 'theme', 'feature'].contains(itemType)) {
      throw ArgumentError('itemType must be one of: powerup, theme, feature');
    }
  }

  static void _validatePrices(int basePrice, int currentPrice) {
    if (basePrice < 0) {
      throw ArgumentError('basePrice must be non-negative');
    }
    if (currentPrice < 0) {
      throw ArgumentError('currentPrice must be non-negative');
    }
  }

  static void _validateDiscountPercentage(int discountPercentage) {
    if (discountPercentage < 0 || discountPercentage > 100) {
      throw ArgumentError('discountPercentage must be between 0 and 100');
    }
  }

  static void _validateIcon(String? icon) {
    if (icon != null && icon.length > 200) {
      throw ArgumentError('icon must be less than 200 characters');
    }
  }

  static void _validateCategory(String? category) {
    if (category != null && category.length > 50) {
      throw ArgumentError('category must be less than 50 characters');
    }
  }

  static void _validateDiscountDates(
      DateTime? discountStart, DateTime? discountEnd) {
    if (discountStart != null &&
        discountEnd != null &&
        discountStart.isAfter(discountEnd)) {
      throw ArgumentError('discountStart must be before discountEnd');
    }
  }

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    // Validate required fields before creating instance
    final itemKey = json['item_key'] ?? '';
    final itemName = json['item_name'] ?? '';
    final itemDescription = json['item_description'] ?? '';
    final itemType = json['item_type'] ?? '';

    _validateItemKey(itemKey);
    _validateItemName(itemName);
    _validateItemDescription(itemDescription);
    _validateItemType(itemType);

    // Parse and validate dates
    DateTime? discountStart;
    DateTime? discountEnd;
    try {
      if (json['discount_start'] != null) {
        discountStart = DateTime.parse(json['discount_start']);
      }
      if (json['discount_end'] != null) {
        discountEnd = DateTime.parse(json['discount_end']);
      }
    } catch (e) {
      throw ArgumentError('Invalid date format in discount dates');
    }

    _validateDiscountDates(discountStart, discountEnd);

    return StoreItem(
      itemKey: itemKey,
      itemName: itemName,
      itemDescription: itemDescription,
      itemType: itemType,
      icon: json['icon'],
      basePrice: json['base_price']?.toInt() ?? 0,
      currentPrice: json['current_price']?.toInt() ?? 0,
      isDiscounted: json['is_discounted'] ?? false,
      discountPercentage: json['discount_percentage']?.toInt() ?? 0,
      isActive: json['is_active'] ?? true,
      category: json['category'],
      discountStart: discountStart,
      discountEnd: discountEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_key': itemKey,
      'item_name': itemName,
      'item_description': itemDescription,
      'item_type': itemType,
      'icon': icon,
      'base_price': basePrice,
      'current_price': currentPrice,
      'is_discounted': isDiscounted,
      'discount_percentage': discountPercentage,
      'is_active': isActive,
      'category': category,
      'discount_start': discountStart?.toIso8601String(),
      'discount_end': discountEnd?.toIso8601String(),
    };
  }

  /// Calculates the discount amount in stars
  int get discountAmount => basePrice - currentPrice;

  /// Gets the discount percentage as a formatted string
  String get discountPercentageString => '$discountPercentage%';

  /// Checks if the item is currently discounted
  bool get isCurrentlyDiscounted {
    if (!isDiscounted) return false;

    // If discount start and end are set, check if we're in the active period
    if (discountStart != null && discountEnd != null) {
      final now = DateTime.now();
      return now.isAfter(discountStart!) && now.isBefore(discountEnd!);
    }

    // If no dates are set but discount is active, it's always discounted
    return isDiscounted;
  }
}
