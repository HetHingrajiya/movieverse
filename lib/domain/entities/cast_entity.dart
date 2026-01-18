class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String? ?? 'Unknown',
      profilePath: json['profile_path'] as String?,
    );
  }
}
