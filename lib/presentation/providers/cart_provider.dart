import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/add_to_cart_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/clear_cart_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/remove_from_cart_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/update_cart_quantity_usecase.dart';

/// Real-time cart for whichever user is currently signed in. [updateUser]
/// is called by a ChangeNotifierProxyProvider whenever AuthProvider's
/// current user changes, so the cart automatically re-scopes on sign
/// in/out instead of leaking the previous user's items.
class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartQuantityUseCase _updateCartQuantityUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final ClearCartUseCase _clearCartUseCase;

  StreamSubscription<List<CartItem>>? _subscription;
  String? _uid;

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider({
    required CartRepository cartRepository,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartQuantityUseCase updateCartQuantityUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required ClearCartUseCase clearCartUseCase,
  })  : _cartRepository = cartRepository,
        _addToCartUseCase = addToCartUseCase,
        _updateCartQuantityUseCase = updateCartQuantityUseCase,
        _removeFromCartUseCase = removeFromCartUseCase,
        _clearCartUseCase = clearCartUseCase;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0, (sum, i) => sum + i.lineTotal);

  void updateUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _subscription?.cancel();

    if (uid == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _subscription = _cartRepository.watchCart(uid).listen(
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Could not load your cart. Please try again.';
        notifyListeners();
      },
    );
  }

  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (_uid == null) return false;
    final result = await _addToCartUseCase(
      (uid: _uid!, product: product, quantity: quantity),
    );
    return result.when(
      success: (_) => true,
      error: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_uid == null) return;
    await _updateCartQuantityUseCase(
      (uid: _uid!, productId: productId, quantity: quantity),
    );
  }

  Future<void> removeItem(String productId) async {
    if (_uid == null) return;
    await _removeFromCartUseCase((uid: _uid!, productId: productId));
  }

  Future<void> clear() async {
    if (_uid == null) return;
    await _clearCartUseCase(_uid!);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
