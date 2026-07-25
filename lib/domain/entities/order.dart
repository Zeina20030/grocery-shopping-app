import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, outForDelivery, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.outForDelivery => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };
}

/// A snapshot of a cart line at the moment an order was placed. Kept
/// separate from [CartItem] so later price changes on the product never
/// retroactively change a past order's total.
class OrderItem extends Equatable {
  final String productId;
  final String name;
  final double price;
  final String unit;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [productId, name, price, unit, quantity];
}

class Order extends Equatable {
  final String id;
  final String uid;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.uid,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, uid, items, totalAmount, status, deliveryAddress, createdAt];
}
