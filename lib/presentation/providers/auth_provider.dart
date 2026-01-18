import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/domain/entities/entities.dart';
import 'package:movieverse/presentation/providers/core_providers.dart';

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});
