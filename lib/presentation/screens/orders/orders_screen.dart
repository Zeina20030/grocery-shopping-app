import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shopping_app/presentation/providers/order_provider.dart';
import 'package:grocery_shopping_app/presentation/screens/orders/order_detail_screen.dart';
import 'package:grocery_shopping_app/presentation/widgets/empty_state.dart';
import 'package:grocery_shopping_app/presentation/widgets/order_tile.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your orders')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Orders you place will show up here in real time.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.orders.length,
            itemBuilder: (context, i) {
              final order = provider.orders[i];
              return OrderTile(
                order: order,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
