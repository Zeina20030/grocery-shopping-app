import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shopping_app/core/di/service_locator.dart';
import 'package:grocery_shopping_app/core/utils/formatters.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/product_repository.dart';
import 'package:grocery_shopping_app/presentation/providers/cart_provider.dart';
import 'package:grocery_shopping_app/presentation/widgets/error_view.dart';
import 'package:grocery_shopping_app/presentation/widgets/primary_button.dart';
import 'package:grocery_shopping_app/presentation/widgets/quantity_stepper.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: StreamBuilder<Product?>(
        stream: sl<ProductRepository>().watchProductById(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const ErrorView(message: 'Could not load this product.');
          }
          final product = snapshot.data;
          if (product == null) {
            return const ErrorView(message: 'This product is no longer available.');
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: product.imageUrl.isEmpty
                      ? const Icon(Icons.image_not_supported_outlined, size: 48)
                      : CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '${formatPrice(product.price)} / ${product.unit}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.inStock ? '${product.stock} in stock' : 'Out of stock',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Text(product.description),
                      const SizedBox(height: 24),
                      if (product.inStock) ...[
                        Row(
                          children: [
                            const Text('Quantity'),
                            const Spacer(),
                            QuantityStepper(
                              quantity: _quantity,
                              min: 1,
                              onChanged: (q) => setState(() => _quantity = q),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Add to cart',
                          onPressed: () async {
                            final added = await context
                                .read<CartProvider>()
                                .addToCart(product, quantity: _quantity);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    added
                                        ? '${product.name} added to cart'
                                        : 'Could not add to cart',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
