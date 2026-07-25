import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';

abstract interface class OrderRepository {
  /// Real-time order history for [uid], newest first.
  Stream<List<Order>> watchOrders(String uid);

  Future<Result<Order>> placeOrder({
    required String uid,
    required List<CartItem> items,
    required String deliveryAddress,
  });
}
