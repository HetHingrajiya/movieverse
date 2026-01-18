import 'package:movieverse/domain/entities/entities.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.description,
    super.posterPath,
    super.backdropPath,
    required super.rating,
    super.releaseDate,
    super.isPremium,
    super.videoUrl,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown Title',
      description: json['overview'] as String? ?? 'No description available',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String?,
      // These are not in TMDB standard response but might be merged from Firestore
      isPremium: json['isPremium'] as bool? ?? false,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  factory MovieModel.fromFirestore(Map<String, dynamic> json) {
    return MovieModel(
      id: json['movieId'] as int, // note: firestore uses movieId
      title: json['title'] as String,
      description: json['description'] as String,
      posterPath: json['posterUrl'] as String?, // mapped from posterUrl
      backdropPath: json['bannerUrl'] as String?, // mapped from bannerUrl
      rating: (json['rating'] as num).toDouble(),
      releaseDate: json['releaseDate'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'movieId': id,
      'title': title,
      'description': description,
      'posterUrl': posterPath,
      'bannerUrl': backdropPath,
      'rating': rating,
      'releaseDate': releaseDate,
      'isPremium': isPremium,
      'videoUrl': videoUrl,
    };
  }
}
