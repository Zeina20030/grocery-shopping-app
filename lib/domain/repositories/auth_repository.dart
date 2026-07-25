import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  /// Emits the current user (or null) immediately on subscription and again
  /// on every sign-in/sign-out -- the single source of truth auth-gated
  /// routing listens to.
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}
