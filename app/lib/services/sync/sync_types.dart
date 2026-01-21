class SyncItem {
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String userId;

  SyncItem({
    required this.key,
    required this.data,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      key: json['key'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
    );
  }
}
