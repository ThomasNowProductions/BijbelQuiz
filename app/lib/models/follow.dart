import 'user.dart';

/// Represents a follow relationship between users
class Follow {
  final String id;
  final String followerId;
  final String followingId;
  final FollowStatus status;
  final DateTime createdAt;

  const Follow({
    required this.id,
    required this.followerId,
    required this.followingId,
    this.status = FollowStatus.active,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      status: FollowStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Follow copyWith({
    String? id,
    String? followerId,
    String? followingId,
    FollowStatus? status,
    DateTime? createdAt,
  }) {
    return Follow(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Follow && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Follow(id: $id, followerId: $followerId, followingId: $followingId)';
  }
}

/// Represents the status of a follow relationship
enum FollowStatus {
  active,
  blocked;

  static FollowStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return FollowStatus.active;
      case 'blocked':
        return FollowStatus.blocked;
      default:
        return FollowStatus.active;
    }
  }

  @override
  String toString() {
    return name;
  }
}

/// Represents a user with follow information
class UserWithFollow {
  final User user;
  final DateTime followedAt;

  const UserWithFollow({
    required this.user,
    required this.followedAt,
  });

  factory UserWithFollow.fromJson(Map<String, dynamic> json) {
    return UserWithFollow(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      followedAt: DateTime.parse(json['followed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'followed_at': followedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserWithFollow && other.user.id == user.id;
  }

  @override
  int get hashCode => user.id.hashCode;

  @override
  String toString() {
    return 'UserWithFollow(user: ${user.username}, followedAt: $followedAt)';
  }
}

/// Represents social statistics for a user
class SocialStats {
  final int followers;
  final int following;

  const SocialStats({
    required this.followers,
    required this.following,
  });

  factory SocialStats.fromJson(Map<String, dynamic> json) {
    return SocialStats(
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followers': followers,
      'following': following,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialStats && 
           other.followers == followers && 
           other.following == following;
  }

  @override
  int get hashCode => followers.hashCode ^ following.hashCode;

  @override
  String toString() {
    return 'SocialStats(followers: $followers, following: $following)';
  }
}

/// Represents a feed item in the social feed
class FeedItem {
  final String type;
  final DateTime timestamp;
  final User user;
  final Map<String, dynamic> data;

  const FeedItem({
    required this.type,
    required this.timestamp,
    required this.user,
    required this.data,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'user': user.toJson(),
      'data': data,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedItem && 
           other.type == type && 
           other.timestamp == timestamp &&
           other.user.id == user.id;
  }

  @override
  int get hashCode => type.hashCode ^ timestamp.hashCode ^ user.id.hashCode;

  @override
  String toString() {
    return 'FeedItem(type: $type, user: ${user.username}, timestamp: $timestamp)';
  }
}