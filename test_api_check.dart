import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  const apiKey = '293c4edbc3cab75405027ee3a1b67983';
  // Use a known movie ID, e.g., 550 (Fight Club) or a popular one.
  // Let's search for "Kantara" first to match user context or just use a popular one.
  // Kantara ID: 934641 (approx, let's trust popular endpoint)

  const popularUrl =
      'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';
  print('Fetching popular movies...');
  try {
    final popResponse = await http.get(Uri.parse(popularUrl));
    if (popResponse.statusCode != 200) {
      print('Failed to fetch popular: ${popResponse.statusCode}');
      return;
    }

    final firstMovieId = json.decode(popResponse.body)['results'][0]['id'];
    print('Testing video fetch for Movie ID: $firstMovieId');

    final videosUrl =
        'https://api.themoviedb.org/3/movie/$firstMovieId/videos?api_key=$apiKey';
    final vidResponse = await http.get(Uri.parse(videosUrl));

    if (vidResponse.statusCode == 200) {
      final data = json.decode(vidResponse.body);
      final results = data['results'] as List;
      print('Found ${results.length} videos.');
      for (var v in results) {
        print('Site: "${v['site']}", Type: "${v['type']}", Key: "${v['key']}"');
      }
    } else {
      print('Failed to fetch videos: ${vidResponse.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
