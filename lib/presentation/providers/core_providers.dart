import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:movieverse/data/repositories/auth_repository_impl.dart';
import 'package:movieverse/data/repositories/firestore_repository_impl.dart';
import 'package:movieverse/data/repositories/movie_repository_impl.dart';
import 'package:movieverse/domain/repositories/repositories.dart';

// HTTP Client
final httpClientProvider = Provider((ref) => http.Client());

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return MovieRepositoryImpl(client: client);
});

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepositoryImpl();
});
