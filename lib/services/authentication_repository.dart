import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

import 'package:babysitterapp/core/providers/firebase_providers.dart';
import 'package:babysitterapp/core/constants.dart';
import 'package:babysitterapp/core/config.dart';

import 'package:babysitterapp/models/user_account.dart';

final Provider<AuthenticationRepository> authenticationRepository =
    Provider<AuthenticationRepository>(
  (ProviderRef<AuthenticationRepository> ref) => AuthenticationRepository(
      ref.read(firebaseAuthProvider),
      ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider),
      ref),
);

class AuthenticationRepository {
  AuthenticationRepository(
    this._firebaseAuth,
    this._firestore,
    this._storage,
    this._ref,
  );

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  // ignore: unused_field
  final Ref _ref;

  Future<Either<String, UserAccount>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // Check if any of the fields are empty
    if (name.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
      return left('Fields cannot be empty');
    }

    try {
      final UserCredential response = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User user = response.user!;

      final UserAccount userAccount = UserAccount(
        id: user.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userAccount.toJson());
      print('User data saved to Firestore: ${userAccount.toJson()}');

      return right(userAccount);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      return left(handleFirebaseAuthException(e));
    } catch (e) {
      print('Exception: $e');
      return left(AuthError.genericError);
    }
  }

  Future<Either<String, UserAccount?>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential response =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User user = response.user!;

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        return left(AuthError.userNotFound);
      }

      final UserAccount userAccount = UserAccount.fromJson(userDoc.data()!);

      return right(userAccount);
    } on FirebaseAuthException catch (e) {
      return left(handleFirebaseAuthException(e));
    } catch (e) {
      return left(AuthError.genericError);
    }
  }

  Future<Either<String, UserAccount>> continueWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: DefaultFirebaseOptions.currentPlatform.iosClientId);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential response =
            await _firebaseAuth.signInWithCredential(credential);
        final User user = response.user!;

        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          return left(AuthError.userNotFound);
        }

        final UserAccount userAccount = UserAccount.fromJson(userDoc.data()!);

        return right(userAccount);
      } else {
        return left(AuthError.unknownError);
      }
    } on FirebaseAuthException catch (e) {
      return left(handleFirebaseAuthException(e));
    } catch (e) {
      return left(AuthError.genericError);
    }
  }

  Future<Either<String, UserAccount>> continueWithFacebook() async {
    return left('Facebook login not implemented');
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<Either<String, UserAccount>> getUser() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(AuthError.userNotFound);
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        return left(AuthError.userNotFound);
      }

      final UserAccount userAccount = UserAccount.fromJson(userDoc.data()!);

      return right(userAccount);
    } catch (e) {
      return left(AuthError.genericError);
    }
  }

  Future<Either<String, void>> deleteAccount() async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(AuthError.userNotFound);
      }

      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();

      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(handleFirebaseAuthException(e));
    } catch (e) {
      return left(AuthError.genericError);
    }
  }

  Future<String?> uploadFile(String path, String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<Either<String, UserAccount>> updateAccount(
      UserAccount updatedUser) async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(AuthError.userNotFound);
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updatedUser.toJson());
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final UserAccount userAccount = UserAccount.fromJson(userDoc.data()!);

      return right(userAccount);
    } catch (e) {
      return left(AuthError.genericError);
    }
  }
}
