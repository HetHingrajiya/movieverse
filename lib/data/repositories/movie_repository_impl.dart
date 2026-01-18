import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:movieverse/core/constants/api_constants.dart';
import 'package:movieverse/core/error/failure.dart';
import 'package:movieverse/data/models/movie_model.dart';
import 'package:movieverse/domain/entities/entities.dart';
import 'package:movieverse/domain/repositories/repositories.dart';

class MovieRepositoryImpl implements MovieRepository {
  final http.Client client;

  MovieRepositoryImpl({required this.client});

  Future<Either<Failure, List<Movie>>> _getMovies(String url) async {
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return Right(results.map((e) => MovieModel.fromJson(e)).toList());
      } else {
        return const Left(ServerFailure('Failed to fetch movies from TMDB'));
      }
    } catch (e) {
      if (e is http.ClientException) {
        return Left(NetworkFailure('Network Error: ${e.message}'));
      }
      return Left(ServerFailure('Exception: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies() {
    return _getMovies(
        '${ApiConstants.baseUrl}/trending/movie/day?api_key=${ApiConstants.apiKey}');
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies() {
    return _getMovies(
        '${ApiConstants.baseUrl}/movie/popular?api_key=${ApiConstants.apiKey}');
  }

  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies() {
    return _getMovies(
        '${ApiConstants.baseUrl}/movie/upcoming?api_key=${ApiConstants.apiKey}');
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies() {
    return _getMovies(
        '${ApiConstants.baseUrl}/movie/top_rated?api_key=${ApiConstants.apiKey}');
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) {
    return _getMovies(
        '${ApiConstants.baseUrl}/search/movie?api_key=${ApiConstants.apiKey}&query=$query');
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int movieId) async {
    // This fetches basic details from TMDB.
    // Video URL and Premium status are handled by Firestore separate calls in common logic,
    // BUT the repository interface returns a Movie.
    // For now, return TMDB data.
    try {
      final response = await client.get(Uri.parse(
          '${ApiConstants.baseUrl}/movie/$movieId?api_key=${ApiConstants.apiKey}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Right(MovieModel.fromJson(data));
      } else {
        return const Left(ServerFailure('Failed to fetch movie details'));
      }
    } catch (e) {
      if (e is http.ClientException) {
        return Left(NetworkFailure('Network Error: ${e.message}'));
      }
      return Left(ServerFailure('Detail Error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getMovieVideos(int movieId) async {
    try {
      final response = await client.get(Uri.parse(
          '${ApiConstants.baseUrl}/movie/$movieId/videos?api_key=${ApiConstants.apiKey}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        // Filter for YouTube trailers
        // Priority: Site=YouTube, Type=Trailer
        final trailers = results
            .where((v) => v['site'] == 'YouTube' && v['type'] == 'Trailer')
            .map((v) => 'https://www.youtube.com/watch?v=${v['key']}')
            .toList();

        // If no Trailer, allow Teaser or Clip
        if (trailers.isEmpty) {
          final others = results
              .where((v) => v['site'] == 'YouTube')
              .map((v) => 'https://www.youtube.com/watch?v=${v['key']}')
              .toList();
          return Right(others.map((e) => e).toList());
        }

        return Right(trailers.map((e) => e).toList());
      } else {
        return const Left(
            ServerFailure('Failed to fetch movie videos from TMDB'));
      }
    } catch (e) {
      if (e is http.ClientException) {
        return Left(NetworkFailure('Network Error: ${e.message}'));
      }
      return Left(ServerFailure('Video Error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Cast>>> getMovieCast(int movieId) async {
    try {
      final response = await client.get(Uri.parse(
          '${ApiConstants.baseUrl}/movie/$movieId/credits?api_key=${ApiConstants.apiKey}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List castList = data['cast'];
        return Right(castList.map((e) => Cast.fromJson(e)).toList());
      } else {
        return const Left(ServerFailure('Failed to fetch movie cast'));
      }
    } catch (e) {
      if (e is http.ClientException) {
        return Left(NetworkFailure('Network Error: ${e.message}'));
      }
      return Left(ServerFailure('Cast Error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int movieId) {
    return _getMovies(
        '${ApiConstants.baseUrl}/movie/$movieId/similar?api_key=${ApiConstants.apiKey}');
  }
}
