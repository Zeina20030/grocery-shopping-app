import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';

typedef UpdateCartQuantityParams = ({
  String uid,
  String productId,
  int quantity,
});

class UpdateCartQuantityUseCase
    implements UseCase<Result<void>, UpdateCartQuantityParams> {
  final CartRepository _repository;

  const UpdateCartQuantityUseCase(this._repository);

  @override
  Future<Result<void>> call(UpdateCartQuantityParams params) async {
    // Business rule: dropping the quantity to zero removes the line
    // entirely rather than leaving a zero-quantity item in the cart.
    if (params.quantity <= 0) {
      return _repository.removeFromCart(
        uid: params.uid,
        productId: params.productId,
      );
    }
    return _repository.updateQuantity(
      uid: params.uid,
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}
