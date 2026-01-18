import 'package:dartz/dartz.dart';
import 'package:movieverse/core/error/failure.dart';
import 'package:movieverse/domain/entities/entities.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getTrendingMovies();
  Future<Either<Failure, List<Movie>>> getPopularMovies();
  Future<Either<Failure, List<Movie>>> getUpcomingMovies();
  Future<Either<Failure, List<Movie>>> searchMovies(String query);
  Future<Either<Failure, Movie>> getMovieDetails(int id);
  Future<Either<Failure, List<String>>> getMovieVideos(int id);
  Future<Either<Failure, List<Cast>>> getMovieCast(int id);
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id);
  Future<Either<Failure, List<Movie>>> getTopRatedMovies();
}
