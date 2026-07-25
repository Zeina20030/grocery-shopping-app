import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firestore_cart_datasource.dart';
import 'package:grocery_shopping_app/data/repositories/cart_repository_impl.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';

const _uid = 'user-1';

const _bananas = Product(
  id: 'bananas',
  name: 'Bananas',
  description: '',
  price: 0.59,
  imageUrl: '',
  category: 'Fruits & Vegetables',
  unit: 'lb',
  stock: 100,
);

void main() {
  late FakeFirebaseFirestore firestore;
  late CartRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = CartRepositoryImpl(FirestoreCartDataSource(firestore));
  });

  test('addToCart creates a new line for a product not yet in the cart', () async {
    final result = await repository.addToCart(uid: _uid, product: _bananas, quantity: 2);

    expect(result, isA<Success<void>>());
    final items = await repository.watchCart(_uid).first;
    expect(items, hasLength(1));
    expect(items.single.quantity, 2);
  });

  test('addToCart increments quantity when the product is already in the cart', () async {
    await repository.addToCart(uid: _uid, product: _bananas, quantity: 2);
    await repository.addToCart(uid: _uid, product: _bananas, quantity: 3);

    final items = await repository.watchCart(_uid).first;
    expect(items, hasLength(1));
    expect(items.single.quantity, 5);
  });

  test('updateQuantity overwrites the stored quantity', () async {
    await repository.addToCart(uid: _uid, product: _bananas, quantity: 2);
    await repository.updateQuantity(uid: _uid, productId: _bananas.id, quantity: 7);

    final items = await repository.watchCart(_uid).first;
    expect(items.single.quantity, 7);
  });

  test('removeFromCart deletes the line', () async {
    await repository.addToCart(uid: _uid, product: _bananas, quantity: 2);
    await repository.removeFromCart(uid: _uid, productId: _bananas.id);

    final items = await repository.watchCart(_uid).first;
    expect(items, isEmpty);
  });

  test('clearCart removes every line for that user', () async {
    await repository.addToCart(uid: _uid, product: _bananas, quantity: 2);
    await repository.addToCart(
      uid: _uid,
      product: const Product(
        id: 'milk',
        name: 'Milk',
        description: '',
        price: 3.49,
        imageUrl: '',
        category: 'Dairy & Eggs',
        unit: 'half-gallon',
        stock: 40,
      ),
      quantity: 1,
    );

    await repository.clearCart(_uid);

    final items = await repository.watchCart(_uid).first;
    expect(items, isEmpty);
  });

  test('carts are scoped per user', () async {
    await repository.addToCart(uid: _uid, product: _bananas, quantity: 2);

    final otherUsersItems = await repository.watchCart('someone-else').first;
    expect(otherUsersItems, isEmpty);
  });
}
