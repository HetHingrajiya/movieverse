import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/core/constants/api_constants.dart';
import 'package:movieverse/domain/entities/entities.dart';
import 'package:movieverse/presentation/providers/auth_provider.dart';
import 'package:movieverse/presentation/providers/core_providers.dart';
import 'package:movieverse/presentation/providers/movie_providers.dart';
import 'package:movieverse/presentation/providers/user_providers.dart';
import 'package:movieverse/presentation/screens/video_player_screen.dart';
import 'package:movieverse/presentation/widgets/primary_button.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailsProvider(movieId));
    final isInWatchlist = ref.watch(isMovieInWatchlistProvider(movieId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: movieAsync.when(
        data: (movie) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.backdropPath != null
                          ? '${ApiConstants.bannerBaseUrl}${movie.backdropPath}'
                          : '${ApiConstants.imageBaseUrl}${movie.posterPath ?? ""}',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                            '${movie.rating.toStringAsFixed(1)}  •  ${(movie.releaseDate != null && movie.releaseDate!.length >= 4) ? movie.releaseDate!.substring(0, 4) : "N/A"}',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(context, ref, movie, currentUser),
                    const SizedBox(height: 24),
                    const Text('Overview',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(movie.description,
                        style:
                            const TextStyle(color: Colors.grey, height: 1.5)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isInWatchlist ? Icons.check : Icons.add,
                              color:
                                  isInWatchlist ? Colors.green : Colors.white),
                          onPressed: () {
                            if (currentUser != null) {
                              final repo =
                                  ref.read(firestoreRepositoryProvider);
                              if (isInWatchlist) {
                                repo.removeFromWatchlist(
                                    currentUser.uid, movieId);
                              } else {
                                repo.addToWatchlist(currentUser.uid, movieId);
                              }
                              // ignore: unused_result
                              ref.refresh(watchlistProvider);
                            }
                          },
                        ),
                        Text(
                            isInWatchlist ? 'In Watchlist' : 'Add to Watchlist',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, Movie movie, UserEntity? user) {
    if (user == null) return const SizedBox.shrink();

    // Check if premium movie
    final isPremiumAsync = ref.watch(isMoviePremiumProvider(movieId));

    return isPremiumAsync.when(
      data: (isPremium) {
        if (isPremium && user.subscriptionType != 'premium') {
          return Container(
            padding: const EdgeInsets.all(12),
            color: Colors.red.withValues(alpha: 0.2),
            child: const Row(
              children: [
                Icon(Icons.lock, color: Colors.red),
                SizedBox(width: 8),
                Text('Premium Subscription Required',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        return PrimaryButton(
          text: 'Watch Now',
          onPressed: () async {
            // Get Video URL relative to movie
            // We need to fetch it first.
            // But 'PrimaryButton' expects sync callback.
            // We can do it async.

            final url = await ref.read(movieVideoUrlProvider(movieId).future);
            if (!context.mounted) return;

            if (url != null && url.isNotEmpty) {
              // Log to watch history
              // user is non-null here due to early return at start of method
              ref
                  .read(firestoreRepositoryProvider)
                  .addToWatchHistory(user.uid, movieId);
              // Refresh history provider roughly
              ref.invalidate(watchHistoryProvider);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          VideoPlayerScreen(videoUrl: url, movieId: movieId)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video not available')));
            }
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }
}
