import 'package:grocery_shopping_app/core/error/exceptions.dart';
import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:grocery_shopping_app/domain/entities/app_user.dart';
import 'package:grocery_shopping_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AppUser?> get authStateChanges => _dataSource.authStateChanges;

  @override
  AppUser? get currentUser => _dataSource.currentUser;

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signIn(email, password);
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } catch (_) {
      return const Result.error(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _dataSource.signUp(email, password, displayName);
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } catch (_) {
      return const Result.error(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<void> signOut() => _dataSource.signOut();
}
