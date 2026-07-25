import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';
import 'package:grocery_shopping_app/domain/repositories/order_repository.dart';
import 'package:grocery_shopping_app/domain/usecases/order/place_order_usecase.dart';

class _FakeOrderRepository implements OrderRepository {
  bool shouldFail = false;

  @override
  Future<Result<Order>> placeOrder({
    required String uid,
    required List<CartItem> items,
    required String deliveryAddress,
  }) async {
    if (shouldFail) {
      return const Result.error(ServerFailure('boom'));
    }
    return Result.success(Order(
      id: 'o1',
      uid: uid,
      items: const [],
      totalAmount: 1.18,
      status: OrderStatus.pending,
      deliveryAddress: deliveryAddress,
      createdAt: DateTime(2026, 1, 1),
    ));
  }

  @override
  Stream<List<Order>> watchOrders(String uid) => const Stream.empty();
}

class _FakeCartRepository implements CartRepository {
  bool clearCartCalled = false;

  @override
  Future<Result<void>> clearCart(String uid) async {
    clearCartCalled = true;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> addToCart({
    required String uid,
    required Product product,
    required int quantity,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> removeFromCart({required String uid, required String productId}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateQuantity({
    required String uid,
    required String productId,
    required int quantity,
  }) =>
      throw UnimplementedError();

  @override
  Stream<List<CartItem>> watchCart(String uid) => const Stream.empty();
}

const _cartItem = CartItem(
  productId: 'p1',
  name: 'Bananas',
  price: 0.59,
  imageUrl: '',
  unit: 'lb',
  quantity: 2,
);

void main() {
  late _FakeOrderRepository orderRepository;
  late _FakeCartRepository cartRepository;
  late PlaceOrderUseCase useCase;

  setUp(() {
    orderRepository = _FakeOrderRepository();
    cartRepository = _FakeCartRepository();
    useCase = PlaceOrderUseCase(orderRepository, cartRepository);
  });

  test('rejects an empty cart', () async {
    final result = await useCase((uid: 'u1', items: [], deliveryAddress: '123 Main St'));

    expect((result as Error).failure, isA<ValidationFailure>());
    expect(cartRepository.clearCartCalled, isFalse);
  });

  test('rejects a blank delivery address', () async {
    final result = await useCase((uid: 'u1', items: [_cartItem], deliveryAddress: '  '));

    expect((result as Error).failure, isA<ValidationFailure>());
    expect(cartRepository.clearCartCalled, isFalse);
  });

  test('clears the cart after successfully placing the order', () async {
    final result =
        await useCase((uid: 'u1', items: [_cartItem], deliveryAddress: '123 Main St'));

    expect(result, isA<Success<Order>>());
    expect(cartRepository.clearCartCalled, isTrue);
  });

  test('does not clear the cart if placing the order fails', () async {
    orderRepository.shouldFail = true;

    final result =
        await useCase((uid: 'u1', items: [_cartItem], deliveryAddress: '123 Main St'));

    expect(result, isA<Error<Order>>());
    expect(cartRepository.clearCartCalled, isFalse);
  });
}
