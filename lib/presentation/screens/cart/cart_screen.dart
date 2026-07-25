import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shopping_app/core/utils/formatters.dart';
import 'package:grocery_shopping_app/presentation/providers/cart_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/order_provider.dart';
import 'package:grocery_shopping_app/presentation/widgets/cart_item_tile.dart';
import 'package:grocery_shopping_app/presentation/widgets/empty_state.dart';
import 'package:grocery_shopping_app/presentation/widgets/primary_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final addressController = TextEditingController();

    final address = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery address'),
        content: TextField(
          controller: addressController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '123 Main St, Springfield'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(addressController.text.trim()),
            child: const Text('Place order'),
          ),
        ],
      ),
    );

    if (address == null || address.isEmpty || !context.mounted) return;

    final orderProvider = context.read<OrderProvider>();
    final order = await orderProvider.placeOrder(cart.items, address);

    if (!context.mounted) return;
    if (order != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed! Track it in the Orders tab.')),
      );
    } else if (orderProvider.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(orderProvider.errorMessage!)));
      orderProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cart.items.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add products from the Shop tab to get started.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cart.items.length,
                  itemBuilder: (context, i) {
                    final item = cart.items[i];
                    return CartItemTile(
                      item: item,
                      onQuantityChanged: (q) => cart.updateQuantity(item.productId, q),
                      onRemove: () => cart.removeItem(item.productId),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            formatPrice(cart.subtotal),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Consumer<OrderProvider>(
                        builder: (context, orderProvider, _) => PrimaryButton(
                          label: 'Checkout',
                          isLoading: orderProvider.isPlacingOrder,
                          onPressed: () => _checkout(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
