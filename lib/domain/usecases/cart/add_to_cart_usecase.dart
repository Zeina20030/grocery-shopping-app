import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';

typedef AddToCartParams = ({String uid, Product product, int quantity});

class AddToCartUseCase implements UseCase<Result<void>, AddToCartParams> {
  final CartRepository _repository;

  const AddToCartUseCase(this._repository);

  @override
  Future<Result<void>> call(AddToCartParams params) async {
    if (params.quantity <= 0) {
      return const Result.error(ValidationFailure('Quantity must be at least 1.'));
    }
    if (!params.product.inStock) {
      return const Result.error(ValidationFailure('This product is out of stock.'));
    }
    if (params.quantity > params.product.stock) {
      return Result.error(
        ValidationFailure('Only ${params.product.stock} left in stock.'),
      );
    }
    return _repository.addToCart(
      uid: params.uid,
      product: params.product,
      quantity: params.quantity,
    );
  }
}
