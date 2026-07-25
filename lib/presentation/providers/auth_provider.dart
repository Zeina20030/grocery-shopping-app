import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/entities/app_user.dart';
import 'package:grocery_shopping_app/domain/repositories/auth_repository.dart';
import 'package:grocery_shopping_app/domain/usecases/auth/sign_in_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/auth/sign_out_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/auth/sign_up_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Auth state for the whole app. Auth-gated routing (see AppRouter) listens
/// to [status]; screens read [currentUser] and call the sign-in/up/out
/// methods, which surface validation and Firebase errors via [errorMessage].
class AuthProvider extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _authRepository;

  late final StreamSubscription<AppUser?> _authSubscription;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _currentUser;
  bool _isSubmitting = false;
  String? _errorMessage;

  AuthProvider({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required AuthRepository authRepository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _authRepository = authRepository {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) => _submit(
        () => _signInUseCase(( email: email, password: password )),
      );

  Future<bool> signUp(String email, String password, String displayName) => _submit(
        () => _signUpUseCase((
          email: email,
          password: password,
          displayName: displayName,
        )),
      );

  Future<void> signOut() => _signOutUseCase(const NoParams());

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _submit(Future<Result<AppUser>> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await action();

    return result.when(
      success: (user) {
        // Set state from the use case's own result immediately, rather
        // than waiting for the authStateChanges stream to re-emit -- the
        // stream's next event isn't guaranteed to already reflect a
        // just-set display name (see FirebaseAuthDataSource.signUp).
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _isSubmitting = false;
        notifyListeners();
        return true;
      },
      error: (failure) {
        _isSubmitting = false;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
