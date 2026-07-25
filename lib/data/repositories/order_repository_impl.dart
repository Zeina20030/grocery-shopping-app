import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firestore_order_datasource.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';
import 'package:grocery_shopping_app/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirestoreOrderDataSource _dataSource;

  const OrderRepositoryImpl(this._dataSource);

  @override
  Stream<List<Order>> watchOrders(String uid) => _dataSource.watchOrders(uid);

  @override
  Future<Result<Order>> placeOrder({
    required String uid,
    required List<CartItem> items,
    required String deliveryAddress,
  }) async {
    try {
      final order = await _dataSource.placeOrder(
        uid: uid,
        items: items,
        deliveryAddress: deliveryAddress,
      );
      return Result.success(order);
    } on FirebaseException catch (e) {
      return Result.error(ServerFailure(e.message ?? 'Firestore error.'));
    } catch (_) {
      return const Result.error(ServerFailure('Could not place order. Please try again.'));
    }
  }
}
