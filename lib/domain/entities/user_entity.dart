class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String profileImage;
  final String subscriptionType; // 'free' or 'premium'
  final String role; // 'user' or 'admin'
  final DateTime createdAt;
  final List<String> watchlist;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.subscriptionType,
    this.role = 'user',
    required this.createdAt,
    required this.watchlist,
  });

  bool get isAdmin => role == 'admin';
}
