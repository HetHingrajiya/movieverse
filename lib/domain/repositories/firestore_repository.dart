import 'package:dartz/dartz.dart';
import 'package:movieverse/core/error/failure.dart';

abstract class FirestoreRepository {
  Future<Either<Failure, void>> addToWatchlist(String uid, int movieId);
  Future<Either<Failure, void>> removeFromWatchlist(String uid, int movieId);
  Future<Either<Failure, List<int>>> getWatchlist(String uid);
  Future<Either<Failure, void>> updateWatchProgress(
      String uid, int movieId, int progress);
  Future<Either<Failure, int>> getWatchProgress(String uid, int movieId);
  Future<Either<Failure, bool>> isMoviePremium(
      int movieId); // Check if Firestore has premium flag
  Future<Either<Failure, String?>> getMovieVideoUrl(int movieId);
  Future<Either<Failure, List<int>>> getWatchHistory(String uid);
  Future<Either<Failure, void>> addToWatchHistory(String uid, int movieId);
  Future<Either<Failure, int>> getUserReviewsCount(String uid);
}
