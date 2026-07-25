import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';

abstract interface class CartRepository {
  /// Real-time cart contents for [uid] -- updates instantly across any
  /// device signed into the same account.
  Stream<List<CartItem>> watchCart(String uid);

  Future<Result<void>> addToCart({
    required String uid,
    required Product product,
    required int quantity,
  });

  Future<Result<void>> updateQuantity({
    required String uid,
    required String productId,
    required int quantity,
  });

  Future<Result<void>> removeFromCart({
    required String uid,
    required String productId,
  });

  Future<Result<void>> clearCart(String uid);
}
