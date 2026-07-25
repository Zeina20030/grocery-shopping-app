import 'package:grocery_shopping_app/domain/entities/product.dart';

abstract interface class ProductRepository {
  /// Real-time product catalog, optionally filtered by category.
  Stream<List<Product>> watchProducts({String? category});

  Stream<Product?> watchProductById(String productId);
}
