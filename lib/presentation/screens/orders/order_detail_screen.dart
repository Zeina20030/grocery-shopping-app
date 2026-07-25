import 'package:flutter/material.dart';
import 'package:grocery_shopping_app/core/utils/formatters.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';
import 'package:grocery_shopping_app/presentation/widgets/status_chip.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id.substring(0, 6).toUpperCase()}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDate(order.createdAt), style: Theme.of(context).textTheme.bodyMedium),
              StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Delivering to', style: Theme.of(context).textTheme.labelLarge),
          Text(order.deliveryAddress),
          const Divider(height: 32),
          Text('Items', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('${item.name} x${item.quantity}')),
                  Text(formatPrice(item.lineTotal)),
                ],
              ),
            ),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              Text(
                formatPrice(order.totalAmount),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
