import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movieverse/core/error/failure.dart';
import 'package:movieverse/core/utils/logger.dart';
import 'package:movieverse/data/models/user_model.dart';
import 'package:movieverse/domain/entities/entities.dart';
import 'package:movieverse/domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  FirebaseAuth? _firebaseAuth;
  GoogleSignIn? _googleSignIn;
  FirebaseFirestore? _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) {
    try {
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
      _googleSignIn = googleSignIn ?? GoogleSignIn();
      _firestore = firestore ?? FirebaseFirestore.instance;
      AppLogger.info(
          'AuthRepositoryImpl', 'Dependencies initialized successfully');
    } catch (e) {
      AppLogger.error(
          'AuthRepositoryImpl', 'Firebase not initialized properly.',
          error: e);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    if (_firebaseAuth == null) {
      return Stream.value(null);
    }
    return _firebaseAuth!.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      if (_firestore == null) {
        return null; // Should not happen if auth works but be safe
      }

      try {
        final doc = await _firestore!.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromFirestore(doc.data()!, user.uid);
        }
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          profileImage: user.photoURL ?? '',
          subscriptionType: 'free',
          role: 'user',
          createdAt: DateTime.now(),
          watchlist: [],
        );
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    if (_firebaseAuth == null || _firestore == null) {
      return const Left(AuthFailure('Firebase not initialized.'));
    }
    try {
      final credential = await _firebaseAuth!
          .signInWithEmailAndPassword(email: email, password: password);

      final doc =
          await _firestore!.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) {
        return const Left(ServerFailure('User profile not found.'));
      }
      return Right(UserModel.fromFirestore(doc.data()!, credential.user!.uid));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Login failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
      String name, String email, String password) async {
    if (_firebaseAuth == null || _firestore == null) {
      return const Left(AuthFailure('Firebase not initialized.'));
    }
    try {
      final credential = await _firebaseAuth!
          .createUserWithEmailAndPassword(email: email, password: password);
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        profileImage: '',
        subscriptionType: 'free',
        role: 'user',
        createdAt: DateTime.now(),
        watchlist: [],
      );

      await _firestore!
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      await credential.user!.updateDisplayName(name);

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (_firebaseAuth == null) {
      return const Right(null); // Already "logged out" effectively
    }
    try {
      if (_googleSignIn != null) await _googleSignIn!.signOut();
      await _firebaseAuth!.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleSignIn() async {
    if (_firebaseAuth == null || _googleSignIn == null || _firestore == null) {
      return const Left(
          AuthFailure('Firebase/Google details not initialized.'));
    }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure('Google Sign-In canceled'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth!.signInWithCredential(credential);
      final user = userCredential.user!;

      final doc = await _firestore!.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          profileImage: user.photoURL ?? '',
          subscriptionType: 'free',
          role: 'user',
          createdAt: DateTime.now(),
          watchlist: [],
        );
        await _firestore!
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore());
        return Right(userModel);
      } else {
        return Right(UserModel.fromFirestore(doc.data()!, user.uid));
      }
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    if (_firebaseAuth == null) {
      return const Left(AuthFailure('Firebase not initialized.'));
    }
    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Reset password failed'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
      {required String name, String? password}) async {
    if (_firebaseAuth == null || _firestore == null) {
      return const Left(AuthFailure('Firebase not initialized.'));
    }
    try {
      final user = _firebaseAuth!.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user logged in.'));
      }

      // Update display name in FirebaseAuth
      await user.updateDisplayName(name);

      // Update password if provided
      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }

      // Update user document in Firestore
      await _firestore!.collection('users').doc(user.uid).update({
        'name': name,
      });

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Update profile failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
