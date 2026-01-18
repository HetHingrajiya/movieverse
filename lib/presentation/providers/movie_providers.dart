import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/domain/entities/entities.dart';
import 'package:movieverse/presentation/providers/core_providers.dart';

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.getTrendingMovies();
  return result.fold(
    (failure) => throw failure,
    (movies) => movies,
  );
});

final popularMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.getPopularMovies();
  return result.fold(
    (failure) => throw failure,
    (movies) => movies,
  );
});

final upcomingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.getUpcomingMovies();
  return result.fold(
    (failure) => throw failure,
    (movies) => movies,
  );
});

final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.getTopRatedMovies();
  return result.fold(
    (failure) => throw failure,
    (movies) => movies,
  );
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  // Basic debounce could be handled in UI or here with timer,
  // but FutureProvider re-fetches when dependency changes.
  // We'll rely on UI debounce to update the StateProvider.

  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.searchMovies(query);
  return result.fold(
    (failure) => throw failure,
    (movies) => movies,
  );
});

final movieDetailsProvider =
    FutureProvider.family<Movie, int>((ref, movieId) async {
  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.getMovieDetails(movieId);
  return result.fold(
    (failure) => throw failure,
    (movie) => movie,
  );
});

final movieCastProvider =
    FutureProvider.family<List<Cast>, int>((ref, movieId) async {
  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.getMovieCast(movieId);
  return result.fold(
    (failure) => [],
    (cast) => cast,
  );
});

final similarMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, movieId) async {
  final repo = ref.watch(movieRepositoryProvider);
  final result = await repo.getSimilarMovies(movieId);
  return result.fold(
    (failure) => [],
    (movies) => movies,
  );
});
