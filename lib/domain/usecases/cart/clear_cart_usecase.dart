import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';

class ClearCartUseCase implements UseCase<Result<void>, String> {
  final CartRepository _repository;

  const ClearCartUseCase(this._repository);

  @override
  Future<Result<void>> call(String uid) => _repository.clearCart(uid);
}
