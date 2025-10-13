/// Represents a purchase made by a user
class Purchase {
  final String id;
  final String userId;
  final String itemType;
  final String itemId;
  final String itemName;
  final int cost;
  final PurchaseStatus status;
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const Purchase({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.cost,
    this.status = PurchaseStatus.completed,
    required this.purchasedAt,
    this.expiresAt,
    this.metadata = const {},
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemType: json['item_type'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      cost: json['cost'] as int,
      status: PurchaseStatus.fromString(json['status'] as String),
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType,
      'item_name': itemName,
      'cost': cost,
      'status': status.toString().split('.').last,
      'purchased_at': purchasedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if the purchase is still valid (not expired)
  bool get isValid {
    if (status != PurchaseStatus.completed) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Check if the purchase is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Purchase copyWith({
    String? id,
    String? userId,
    String? itemType,
    String? itemId,
    String? itemName,
    int? cost,
    PurchaseStatus? status,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Purchase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Purchase(id: $id, itemName: $itemName, cost: $cost, status: $status)';
  }
}

/// Represents the status of a purchase
enum PurchaseStatus {
  pending,
  completed,
  refunded;

  static PurchaseStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PurchaseStatus.pending;
      case 'completed':
        return PurchaseStatus.completed;
      case 'refunded':
        return PurchaseStatus.refunded;
      default:
        return PurchaseStatus.pending;
    }
  }

  @override
  String toString() {
    return name;
  }
}

/// Represents an item available for purchase in the store
class StoreItem {
  final String id;
  final String type;
  final String name;
  final String description;
  final int cost;
  final bool permanent;
  final bool consumable;
  final int? duration; // for temporary items
  final Map<String, dynamic> metadata;

  const StoreItem({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.cost,
    this.permanent = false,
    this.consumable = false,
    this.duration,
    this.metadata = const {},
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      cost: json['cost'] as int,
      permanent: json['permanent'] as bool? ?? false,
      consumable: json['consumable'] as bool? ?? false,
      duration: json['duration'] as int?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'cost': cost,
      'permanent': permanent,
      'consumable': consumable,
      'duration': duration,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StoreItem(id: $id, name: $name, cost: $cost)';
  }
}