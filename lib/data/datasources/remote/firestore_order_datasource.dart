import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shopping_app/core/constants/firestore_paths.dart';
import 'package:grocery_shopping_app/data/models/order_model.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';

class FirestoreOrderDataSource {
  final FirebaseFirestore _firestore;

  const FirestoreOrderDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestorePaths.orders);

  Stream<List<OrderModel>> watchOrders(String uid) {
    return _orders
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromFirestore).toList());
  }

  Future<OrderModel> placeOrder({
    required String uid,
    required List<CartItem> items,
    required String deliveryAddress,
  }) async {
    final orderItems = items.map(OrderItemModel.fromCartItem).toList();
    final totalAmount = orderItems.fold<double>(0, (total, i) => total + i.lineTotal);

    final docRef = await _orders.add(
      OrderModel.toMapForCreate(
        uid: uid,
        items: orderItems,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
      ),
    );

    final saved = await docRef.get();
    return OrderModel.fromFirestore(saved);
  }
}
