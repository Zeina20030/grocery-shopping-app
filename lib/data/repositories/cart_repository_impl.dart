import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firestore_cart_datasource.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final FirestoreCartDataSource _dataSource;

  const CartRepositoryImpl(this._dataSource);

  @override
  Stream<List<CartItem>> watchCart(String uid) => _dataSource.watchCart(uid);

  @override
  Future<Result<void>> addToCart({
    required String uid,
    required Product product,
    required int quantity,
  }) => _guard(() => _dataSource.addToCart(uid, product, quantity));

  @override
  Future<Result<void>> updateQuantity({
    required String uid,
    required String productId,
    required int quantity,
  }) => _guard(() => _dataSource.updateQuantity(uid, productId, quantity));

  @override
  Future<Result<void>> removeFromCart({
    required String uid,
    required String productId,
  }) => _guard(() => _dataSource.removeFromCart(uid, productId));

  @override
  Future<Result<void>> clearCart(String uid) =>
      _guard(() => _dataSource.clearCart(uid));

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.error(ServerFailure(e.message ?? 'Firestore error.'));
    } catch (_) {
      return const Result.error(ServerFailure('Something went wrong. Please try again.'));
    }
  }
}
