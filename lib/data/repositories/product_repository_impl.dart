import 'package:grocery_shopping_app/data/datasources/remote/firestore_product_datasource.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirestoreProductDataSource _dataSource;

  const ProductRepositoryImpl(this._dataSource);

  @override
  Stream<List<Product>> watchProducts({String? category}) =>
      _dataSource.watchProducts(category: category);

  @override
  Stream<Product?> watchProductById(String productId) =>
      _dataSource.watchProductById(productId);
}
