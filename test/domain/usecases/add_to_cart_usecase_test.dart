import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/add_to_cart_usecase.dart';

class _FakeCartRepository implements CartRepository {
  bool addToCartCalled = false;

  @override
  Future<Result<void>> addToCart({
    required String uid,
    required Product product,
    required int quantity,
  }) async {
    addToCartCalled = true;
    return const Result.success(null);
  }

  @override
  Stream<List<CartItem>> watchCart(String uid) => const Stream.empty();

  @override
  Future<Result<void>> updateQuantity({
    required String uid,
    required String productId,
    required int quantity,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> removeFromCart({required String uid, required String productId}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> clearCart(String uid) => throw UnimplementedError();
}

const _product = Product(
  id: 'p1',
  name: 'Bananas',
  description: 'Fresh bananas',
  price: 0.59,
  imageUrl: '',
  category: 'Fruits & Vegetables',
  unit: 'lb',
  stock: 5,
);

void main() {
  late _FakeCartRepository repository;
  late AddToCartUseCase useCase;

  setUp(() {
    repository = _FakeCartRepository();
    useCase = AddToCartUseCase(repository);
  });

  test('rejects a zero or negative quantity', () async {
    final result = await useCase((uid: 'u1', product: _product, quantity: 0));

    expect((result as Error).failure, isA<ValidationFailure>());
    expect(repository.addToCartCalled, isFalse);
  });

  test('rejects an out-of-stock product', () async {
    const outOfStock = Product(
      id: 'p2',
      name: 'Ice Cream',
      description: '',
      price: 5,
      imageUrl: '',
      category: 'Frozen',
      unit: 'qt',
      stock: 0,
    );

    final result = await useCase((uid: 'u1', product: outOfStock, quantity: 1));

    expect((result as Error).failure, isA<ValidationFailure>());
    expect(repository.addToCartCalled, isFalse);
  });

  test('rejects a quantity above available stock', () async {
    final result = await useCase((uid: 'u1', product: _product, quantity: 10));

    expect((result as Error).failure, isA<ValidationFailure>());
    expect(repository.addToCartCalled, isFalse);
  });

  test('adds to cart when quantity is within stock', () async {
    final result = await useCase((uid: 'u1', product: _product, quantity: 2));

    expect(result, isA<Success<void>>());
    expect(repository.addToCartCalled, isTrue);
  });
}
