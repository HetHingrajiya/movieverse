import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/presentation/providers/auth_provider.dart';
import 'package:movieverse/presentation/providers/core_providers.dart';

final watchlistProvider = FutureProvider<List<int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(firestoreRepositoryProvider);
  final result = await repo.getWatchlist(user.uid);
  return result.fold(
    (failure) => [],
    (list) => list,
  );
});

final isMovieInWatchlistProvider = Provider.family<bool, int>((ref, movieId) {
  final watchlistAsync = ref.watch(watchlistProvider);
  return watchlistAsync.when(
    data: (list) => list.contains(movieId),
    loading: () => false,
    error: (_, __) => false,
  );
});

// Video URL Provider
final movieVideoUrlProvider =
    FutureProvider.family<String?, int>((ref, movieId) async {
  final fsRepo = ref.watch(firestoreRepositoryProvider);
  final movieRepo = ref.watch(movieRepositoryProvider);

  // 1. Try Firestore (Custom/Override URL)
  final fsResult = await fsRepo.getMovieVideoUrl(movieId);
  final fsUrl = fsResult.fold((top) => null, (url) => url);
  if (fsUrl != null && fsUrl.isNotEmpty) return fsUrl;

  // 2. Try TMDB (Official Trailers)
  final tmdbResult = await movieRepo.getMovieVideos(movieId);
  return tmdbResult.fold(
    (l) => null,
    (videos) => videos.isNotEmpty ? videos.first : null,
  );
});

// Premium Status Provider
final isMoviePremiumProvider =
    FutureProvider.family<bool, int>((ref, movieId) async {
  final repo = ref.watch(firestoreRepositoryProvider);
  final result = await repo.isMoviePremium(movieId);
  return result.fold((l) => false, (r) => r);
});
final watchHistoryProvider = FutureProvider<List<int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(firestoreRepositoryProvider);
  final result = await repo.getWatchHistory(user.uid);
  return result.fold(
    (failure) => [],
    (list) => list,
  );
});

final userReviewsCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final repo = ref.watch(firestoreRepositoryProvider);
  final result = await repo.getUserReviewsCount(user.uid);
  return result.fold(
    (failure) => 0,
    (count) => count,
  );
});
