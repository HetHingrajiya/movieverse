import 'package:dartz/dartz.dart';
import 'package:movieverse/core/error/failure.dart';
import 'package:movieverse/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
      String name, String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> googleSignIn();
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> updateProfile(
      {required String name, String? password});
}
