import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';

typedef RemoveFromCartParams = ({String uid, String productId});

class RemoveFromCartUseCase
    implements UseCase<Result<void>, RemoveFromCartParams> {
  final CartRepository _repository;

  const RemoveFromCartUseCase(this._repository);

  @override
  Future<Result<void>> call(RemoveFromCartParams params) {
    return _repository.removeFromCart(
      uid: params.uid,
      productId: params.productId,
    );
  }
}
