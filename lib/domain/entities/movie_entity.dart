class Movie {
  final int id;
  final String title;
  final String description;
  final String? posterPath;
  final String? backdropPath;
  final double rating;
  final String? releaseDate;
  final bool isPremium;
  final String? videoUrl;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    this.posterPath,
    this.backdropPath,
    required this.rating,
    this.releaseDate,
    this.isPremium = false,
    this.videoUrl,
  });
}
