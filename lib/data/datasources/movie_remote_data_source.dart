import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movieverse/core/constants/app_constants.dart';
import 'package:movieverse/data/models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies();
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getUpcomingMovies();
  Future<List<MovieModel>> searchMovies(String query);
  Future<MovieModel> getMovieDetails(int id);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final http.Client _client;

  MovieRemoteDataSourceImpl(this._client);

  Future<List<MovieModel>> _getMovies(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}$path').replace(
      queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        ...?params,
      },
    );

    try {
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(data['results']);
        return results.map((json) => MovieModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<MovieModel>> getTrendingMovies() => _getMovies('/trending/movie/week');

  @override
  Future<List<MovieModel>> getPopularMovies() => _getMovies('/movie/popular');

  @override
  Future<List<MovieModel>> getUpcomingMovies() => _getMovies('/movie/upcoming');

  @override
  Future<List<MovieModel>> searchMovies(String query) => 
      _getMovies('/search/movie', params: {'query': query});

  @override
  Future<MovieModel> getMovieDetails(int id) async {
    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}/movie/$id').replace(
      queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        'append_to_response': 'videos,credits,similar',
      },
    );

    try {
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        return MovieModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
