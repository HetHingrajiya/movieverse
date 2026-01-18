import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:movieverse/core/error/failure.dart';
import 'package:movieverse/core/utils/logger.dart';
import 'package:movieverse/domain/repositories/repositories.dart';

class FirestoreRepositoryImpl implements FirestoreRepository {
  FirebaseFirestore? _firestore;

  FirestoreRepositoryImpl({FirebaseFirestore? firestore}) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      AppLogger.info('FirestoreRepositoryImpl', 'Initialized successfully');
    } catch (e) {
      AppLogger.error('FirestoreRepositoryImpl', 'Firebase not initialized.',
          error: e);
    }
  }

  @override
  Future<Either<Failure, void>> addToWatchlist(String uid, int movieId) async {
    if (_firestore == null) {
      return const Left(ServerFailure('Firebase not initialized'));
    }
    try {
      await _firestore!.collection('users').doc(uid).update({
        'watchlist': FieldValue.arrayUnion([movieId])
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWatchlist(
      String uid, int movieId) async {
    if (_firestore == null) {
      return const Left(ServerFailure('Firebase not initialized'));
    }
    try {
      await _firestore!.collection('users').doc(uid).update({
        'watchlist': FieldValue.arrayRemove([movieId])
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getWatchlist(String uid) async {
    if (_firestore == null) {
      return const Right(
          []); // Return empty list instead of error for smooth UI
    }
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists) {
        final List<dynamic> list = doc.data()?['watchlist'] ?? [];
        return Right(list.map((e) => e as int).toList());
      }
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWatchProgress(
      String uid, int movieId, int progress) async {
    if (_firestore == null) {
      return const Left(ServerFailure('Firebase not initialized'));
    }
    try {
      // Logic for watch_history collection
      // watch_history: - uid - movieId - progress - watchedAt
      // We'll use a composite ID or query to find the doc.
      // Easiest is to make ID = uid_movieId
      await _firestore!.collection('watch_history').doc('${uid}_$movieId').set({
        'uid': uid,
        'movieId': movieId,
        'progress': progress,
        'watchedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getWatchProgress(String uid, int movieId) async {
    if (_firestore == null) return const Right(0);
    try {
      final doc = await _firestore!
          .collection('watch_history')
          .doc('${uid}_$movieId')
          .get();
      if (doc.exists) {
        return Right(doc.data()?['progress'] as int? ?? 0);
      }
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isMoviePremium(int movieId) async {
    if (_firestore == null) return const Right(false); // Valid assumption
    try {
      // Query "movies" collection by movieId (which is int)
      // Assuming 'movies' collection uses movieId as document ID or has a field 'movieId'
      // Plan said: movies: - movieId...
      // Let's assume document ID is the movieId string, or we query.
      // Using movieId as Doc ID is best practice if unique.
      final doc =
          await _firestore!.collection('movies').doc(movieId.toString()).get();
      if (doc.exists) {
        return Right(doc.data()?['isPremium'] as bool? ?? false);
      }
      return const Right(
          false); // Default to free if not found (or true? Standard practice: free unless marked premium)
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getMovieVideoUrl(int movieId) async {
    if (_firestore == null) return const Right(null);
    try {
      final doc =
          await _firestore!.collection('movies').doc(movieId.toString()).get();
      if (doc.exists) {
        return Right(doc.data()?['videoUrl'] as String?);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getWatchHistory(String uid) async {
    if (_firestore == null) return const Right([]);
    try {
      final snapshot = await _firestore!
          .collection('watch_history')
          .where('uid', isEqualTo: uid)
          .orderBy('watchedAt', descending: true)
          .get();

      final movieIds =
          snapshot.docs.map((doc) => doc.data()['movieId'] as int).toList();
      return Right(movieIds);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWatchHistory(
      String uid, int movieId) async {
    return updateWatchProgress(uid, movieId, 0); // Initialize history
  }

  @override
  Future<Either<Failure, int>> getUserReviewsCount(String uid) async {
    if (_firestore == null) return const Right(0);
    try {
      final snapshot = await _firestore!
          .collection('reviews')
          .where('userId', isEqualTo: uid)
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
