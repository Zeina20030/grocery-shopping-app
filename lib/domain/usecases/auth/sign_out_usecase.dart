import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  const SignOutUseCase(this._repository);

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}
