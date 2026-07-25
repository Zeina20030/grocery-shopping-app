import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/entities/app_user.dart';
import 'package:grocery_shopping_app/domain/repositories/auth_repository.dart';

typedef SignUpParams = ({String email, String password, String displayName});

class SignUpUseCase implements UseCase<Result<AppUser>, SignUpParams> {
  final AuthRepository _repository;

  const SignUpUseCase(this._repository);

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Future<Result<AppUser>> call(SignUpParams params) async {
    if (!_emailPattern.hasMatch(params.email)) {
      return const Result.error(ValidationFailure('Enter a valid email address.'));
    }
    if (params.password.length < 6) {
      return const Result.error(
        ValidationFailure('Password must be at least 6 characters.'),
      );
    }
    if (params.displayName.trim().isEmpty) {
      return const Result.error(ValidationFailure('Enter your name.'));
    }
    return _repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName.trim(),
    );
  }
}
