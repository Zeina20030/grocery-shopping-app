import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shopping_app/core/utils/formatters.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/presentation/widgets/quantity_stepper.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: item.imageUrl.isEmpty
                ? const Icon(Icons.image_not_supported_outlined)
                : CachedNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover),
          ),
        ),
        title: Text(item.name),
        subtitle: Text('${formatPrice(item.price)} / ${item.unit}'),
        trailing: QuantityStepper(
          quantity: item.quantity,
          onChanged: onQuantityChanged,
        ),
      ),
    );
  }
}
