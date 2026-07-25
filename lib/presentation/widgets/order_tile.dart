import 'package:flutter/material.dart';
import 'package:grocery_shopping_app/core/utils/formatters.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';
import 'package:grocery_shopping_app/presentation/widgets/status_chip.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderTile({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text('Order #${order.id.substring(0, 6).toUpperCase()}'),
        subtitle: Text('$itemCount item${itemCount == 1 ? '' : 's'} • ${formatDate(order.createdAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatPrice(order.totalAmount),
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            StatusChip(status: order.status),
          ],
        ),
      ),
    );
  }
}
