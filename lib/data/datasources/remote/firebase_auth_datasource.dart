import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:grocery_shopping_app/core/constants/firestore_paths.dart';
import 'package:grocery_shopping_app/core/error/exceptions.dart';
import 'package:grocery_shopping_app/data/models/app_user_model.dart';

/// Thin wrapper around FirebaseAuth: translates FirebaseAuthException into
/// the app's own [AuthException] so nothing above the data layer needs to
/// know about Firebase-specific error codes.
class FirebaseAuthDataSource {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  const FirebaseAuthDataSource(this._auth, this._firestore);

  Stream<AppUserModel?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user == null ? null : AppUserModel.fromFirebaseUser(user),
      );

  AppUserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : AppUserModel.fromFirebaseUser(user);
  }

  Future<AppUserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed. Please try again.');
      }
      return AppUserModel.fromFirebaseUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<AppUserModel> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }
      await user.updateDisplayName(displayName);
      // Without this, FirebaseAuth's cached User (and therefore the next
      // authStateChanges/currentUser read) can still report the
      // pre-update displayName -- reload() forces it to pick up the
      // change we just made.
      await user.reload();

      // Mirror the profile into Firestore so other users' orders/admin
      // tooling can look up a display name without calling Admin SDK auth.
      await _firestore.collection(FirestorePaths.users).doc(user.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AppUserModel(uid: user.uid, email: email, displayName: displayName);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _messageFor(String code) => switch (code) {
        'invalid-email' => 'That email address looks invalid.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' || 'invalid-credential' => 'Incorrect email or password.',
        'wrong-password' => 'Incorrect email or password.',
        'email-already-in-use' => 'An account already exists for that email.',
        'weak-password' => 'Password is too weak.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => 'Something went wrong. Please try again.',
      };
}
