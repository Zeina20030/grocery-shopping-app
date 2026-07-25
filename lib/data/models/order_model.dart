import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.name,
    required super.price,
    required super.unit,
    required super.quantity,
  });

  factory OrderItemModel.fromCartItem(CartItem item) => OrderItemModel(
        productId: item.productId,
        name: item.name,
        price: item.price,
        unit: item.unit,
        quantity: item.quantity,
      );

  factory OrderItemModel.fromMap(Map<String, dynamic> map) => OrderItemModel(
        productId: map['productId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        unit: map['unit'] as String? ?? 'each',
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'price': price,
        'unit': unit,
        'quantity': quantity,
      };
}

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.uid,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.deliveryAddress,
    required super.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final rawItems = (data['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(OrderItemModel.fromMap)
        .toList();
    final rawStatus = data['status'] as String? ?? 'pending';

    return OrderModel(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      items: rawItems,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == rawStatus,
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toMapForCreate({
    required String uid,
    required List<OrderItemModel> items,
    required double totalAmount,
    required String deliveryAddress,
  }) =>
      {
        'uid': uid,
        'items': items.map((i) => i.toMap()).toList(),
        'totalAmount': totalAmount,
        'status': OrderStatus.pending.name,
        'deliveryAddress': deliveryAddress,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
