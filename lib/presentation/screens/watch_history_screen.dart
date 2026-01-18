import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/core/constants/api_constants.dart';
import 'package:movieverse/presentation/providers/movie_providers.dart';
import 'package:movieverse/presentation/providers/user_providers.dart';
import 'package:movieverse/presentation/screens/movie_detail_screen.dart';

class WatchHistoryScreen extends ConsumerWidget {
  const WatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text('Watch History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: historyAsync.when(
        data: (movieIds) {
          if (movieIds.isEmpty) {
            return const Center(
              child: Text(
                'No watch history yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: movieIds.length,
            itemBuilder: (context, index) {
              final movieId = movieIds[index];
              final movieAsync = ref.watch(movieDetailsProvider(movieId));

              return movieAsync.when(
                data: (movie) => ListTile(
                  leading: movie.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl:
                              '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[900]),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Container(width: 50, color: Colors.grey),
                  title: Text(
                    movie.title,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Watched recently',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movieId: movie.id),
                      ),
                    );
                  },
                ),
                loading: () => const SizedBox(height: 72),
                error: (err, _) => const SizedBox.shrink(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
