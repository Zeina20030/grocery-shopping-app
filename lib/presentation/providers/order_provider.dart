import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';
import 'package:grocery_shopping_app/domain/repositories/order_repository.dart';
import 'package:grocery_shopping_app/domain/usecases/order/place_order_usecase.dart';

/// Real-time order history for whichever user is currently signed in.
/// Re-scoped on auth changes the same way as [CartProvider].
class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final PlaceOrderUseCase _placeOrderUseCase;

  StreamSubscription<List<Order>>? _subscription;
  String? _uid;

  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isPlacingOrder = false;
  String? _errorMessage;

  OrderProvider({
    required OrderRepository orderRepository,
    required PlaceOrderUseCase placeOrderUseCase,
  })  : _orderRepository = orderRepository,
        _placeOrderUseCase = placeOrderUseCase;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get errorMessage => _errorMessage;

  void updateUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _subscription?.cancel();

    if (uid == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _subscription = _orderRepository.watchOrders(uid).listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Could not load your orders. Please try again.';
        notifyListeners();
      },
    );
  }

  Future<Order?> placeOrder(List<CartItem> items, String deliveryAddress) async {
    if (_uid == null) return null;
    _isPlacingOrder = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _placeOrderUseCase(
      (uid: _uid!, items: items, deliveryAddress: deliveryAddress),
    );

    return result.when(
      success: (order) {
        _isPlacingOrder = false;
        notifyListeners();
        return order;
      },
      error: (failure) {
        _isPlacingOrder = false;
        _errorMessage = failure.message;
        notifyListeners();
        return null;
      },
    );
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
