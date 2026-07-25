import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firestore_product_datasource.dart';
import 'package:grocery_shopping_app/data/repositories/product_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProductRepositoryImpl repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = ProductRepositoryImpl(FirestoreProductDataSource(firestore));

    await firestore.collection('products').doc('bananas').set({
      'name': 'Bananas',
      'description': 'Fresh bananas',
      'price': 0.59,
      'imageUrl': '',
      'category': 'Fruits & Vegetables',
      'unit': 'lb',
      'stock': 100,
    });
    await firestore.collection('products').doc('milk').set({
      'name': 'Whole Milk',
      'description': 'Dairy',
      'price': 3.49,
      'imageUrl': '',
      'category': 'Dairy & Eggs',
      'unit': 'half-gallon',
      'stock': 40,
    });
  });

  test('watchProducts emits every product ordered by name', () async {
    final products = await repository.watchProducts().first;

    expect(products.map((p) => p.name), ['Bananas', 'Whole Milk']);
  });

  test('watchProducts filters by category', () async {
    final products = await repository.watchProducts(category: 'Dairy & Eggs').first;

    expect(products, hasLength(1));
    expect(products.single.name, 'Whole Milk');
  });

  test('watchProducts re-emits when a product changes in real time', () async {
    final stream = repository.watchProducts();
    final emissions = <int>[];
    final subscription = stream.listen((products) => emissions.add(products.length));

    await Future<void>.delayed(Duration.zero);
    await firestore.collection('products').doc('eggs').set({
      'name': 'Eggs',
      'description': '',
      'price': 4.19,
      'imageUrl': '',
      'category': 'Dairy & Eggs',
      'unit': 'dozen',
      'stock': 12,
    });
    await Future<void>.delayed(Duration.zero);

    expect(emissions.last, 3);
    await subscription.cancel();
  });

  test('watchProductById emits null once the product is deleted', () async {
    final docRef = firestore.collection('products').doc('bananas');
    final stream = repository.watchProductById('bananas');
    final emissions = <bool>[];
    final subscription = stream.listen((product) => emissions.add(product != null));

    await Future<void>.delayed(Duration.zero);
    await docRef.delete();
    await Future<void>.delayed(Duration.zero);

    expect(emissions, [true, false]);
    await subscription.cancel();
  });
}
