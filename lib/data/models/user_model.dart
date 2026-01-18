import 'package:movieverse/domain/entities/entities.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.profileImage,
    required super.subscriptionType,
    required super.role,
    required super.createdAt,
    required super.watchlist,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      subscriptionType: json['subscriptionType'] as String? ?? 'free',
      role: json['role'] as String? ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      watchlist: (json['watchlist'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'subscriptionType': subscriptionType,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'watchlist': watchlist,
    };
  }
}
