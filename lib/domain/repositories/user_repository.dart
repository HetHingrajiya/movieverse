import 'package:movieverse/domain/entities/entities.dart';

abstract class UserRepository {
  Future<void> addToWatchlist(String uid, int movieId);
  Future<void> removeFromWatchlist(String uid, int movieId);
  Future<List<Movie>> getWatchlistMovies(List<String> movieIds);
  Future<void> updateSubscription(String uid, String plan);
}
