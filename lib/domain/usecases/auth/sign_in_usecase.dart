import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/entities/app_user.dart';
import 'package:grocery_shopping_app/domain/repositories/auth_repository.dart';

typedef SignInParams = ({String email, String password});

class SignInUseCase implements UseCase<Result<AppUser>, SignInParams> {
  final AuthRepository _repository;

  const SignInUseCase(this._repository);

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Future<Result<AppUser>> call(SignInParams params) async {
    if (!_emailPattern.hasMatch(params.email)) {
      return const Result.error(ValidationFailure('Enter a valid email address.'));
    }
    if (params.password.isEmpty) {
      return const Result.error(ValidationFailure('Password cannot be empty.'));
    }
    return _repository.signIn(email: params.email, password: params.password);
  }
}
