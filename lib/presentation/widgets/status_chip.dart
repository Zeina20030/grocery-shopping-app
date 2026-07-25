import 'package:flutter/material.dart';
import 'package:grocery_shopping_app/domain/entities/order.dart';

class StatusChip extends StatelessWidget {
  final OrderStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      OrderStatus.pending => (Colors.orange.shade100, Colors.orange.shade900),
      OrderStatus.confirmed => (Colors.blue.shade100, Colors.blue.shade900),
      OrderStatus.outForDelivery => (Colors.purple.shade100, Colors.purple.shade900),
      OrderStatus.delivered => (Colors.green.shade100, Colors.green.shade900),
      OrderStatus.cancelled => (Colors.red.shade100, Colors.red.shade900),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
