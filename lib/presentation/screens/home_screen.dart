import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/domain/entities/entities.dart';
import 'package:movieverse/presentation/providers/movie_providers.dart';
import 'package:movieverse/presentation/widgets/movie_banner.dart';
import 'package:movieverse/presentation/widgets/movie_card.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingMoviesProvider);
    final popularAsync = ref.watch(popularMoviesProvider);
    final upcomingAsync = ref.watch(upcomingMoviesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: true,
            title: const Text('Movieverse',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                  icon: const Icon(Icons.cast, color: Colors.white),
                  onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: trendingAsync.when(
              data: (movies) => MovieBanner(movies: movies),
              loading: () => _buildBannerShimmer(),
              error: (err, _) => const SizedBox(
                  height: 250,
                  child: Center(
                      child: Text('Error loading banner',
                          style: TextStyle(color: Colors.white)))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: _buildSectionTitle('Trending Now'),
            ),
          ),
          SliverToBoxAdapter(
            child: trendingAsync.when(
              data: (movies) => _buildHorizontalList(movies),
              loading: () => _buildListShimmer(),
              error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.white))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: _buildSectionTitle('Popular'),
            ),
          ),
          SliverToBoxAdapter(
            child: popularAsync.when(
              data: (movies) => _buildHorizontalList(movies),
              loading: () => _buildListShimmer(),
              error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.white))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: _buildSectionTitle('Upcoming'),
            ),
          ),
          SliverToBoxAdapter(
            child: upcomingAsync.when(
              data: (movies) => _buildHorizontalList(movies),
              loading: () => _buildListShimmer(),
              error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.white))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: _buildSectionTitle('Top Rated'),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final topRatedAsync = ref.watch(topRatedMoviesProvider);
                return topRatedAsync.when(
                  data: (movies) => _buildHorizontalList(movies),
                  loading: () => _buildListShimmer(),
                  error: (err, stack) => Center(
                      child: Text('Error: $err',
                          style: const TextStyle(color: Colors.white))),
                );
              },
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHorizontalList(List<Movie> movies) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return MovieCard(movie: movies[index]);
        },
      ),
    );
  }

  Widget _buildBannerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: Container(height: 250, color: Colors.grey[850]),
    );
  }

  Widget _buildListShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[850]!,
              highlightColor: Colors.grey[800]!,
              child: Container(width: 120, color: Colors.grey[850]),
            ),
          );
        },
      ),
    );
  }
}
