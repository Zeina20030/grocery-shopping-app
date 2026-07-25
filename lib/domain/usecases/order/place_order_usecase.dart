import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/core/usecase/usecase.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';
import 'package:grocery_shopping_app/domain/repositories/order_repository.dart';

typedef PlaceOrderParams = ({
  String uid,
  List<CartItem> items,
  String deliveryAddress,
});

/// Orchestrates checkout across two repositories: creates the order, then
/// clears the cart -- exactly the kind of cross-repository coordination
/// use cases exist for, as opposed to a single repository pass-through.
class PlaceOrderUseCase implements UseCase<Result<Order>, PlaceOrderParams> {
  final OrderRepository _orderRepository;
  final CartRepository _cartRepository;

  const PlaceOrderUseCase(this._orderRepository, this._cartRepository);

  @override
  Future<Result<Order>> call(PlaceOrderParams params) async {
    if (params.items.isEmpty) {
      return const Result.error(ValidationFailure('Your cart is empty.'));
    }
    if (params.deliveryAddress.trim().isEmpty) {
      return const Result.error(ValidationFailure('Enter a delivery address.'));
    }

    final result = await _orderRepository.placeOrder(
      uid: params.uid,
      items: params.items,
      deliveryAddress: params.deliveryAddress.trim(),
    );

    return result.when(
      success: (order) async {
        await _cartRepository.clearCart(params.uid);
        return Result.success(order);
      },
      error: (failure) async => Result.error(failure),
    );
  }
}
