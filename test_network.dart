import 'package:http/http.dart' as http;
import 'package:movieverse/core/constants/api_constants.dart';

import 'dart:io';
import 'package:movieverse/core/network/http_overrides.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides(); // Enable bypass
  print('Testing TMDB API Connection (with SSL Bypass)...');

  var client = http.Client(); // Use an http client for better control

  // 2. Test generic TMDB URL (using project constants)
  final url = Uri.parse(
      '${ApiConstants.baseUrl}/movie/top_rated?api_key=${ApiConstants.apiKey}');
  print('Testing TMDB API: $url');

  try {
    final response = await client.get(url);
    print('TMDB Response Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('TMDB Connectivity Success!');
      print('Response length: ${response.body.length}');
      // Optional: Print first 100 chars to verify content
      print('Snippet: ${response.body.substring(0, 100)}');
    } else {
      print('TMDB Failed: ${response.reasonPhrase}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('TMDB Error: $e');
  } finally {
    client.close();
  }
}
