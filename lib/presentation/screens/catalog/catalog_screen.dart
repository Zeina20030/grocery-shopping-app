import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shopping_app/core/constants/app_categories.dart';
import 'package:grocery_shopping_app/presentation/providers/cart_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/product_provider.dart';
import 'package:grocery_shopping_app/presentation/widgets/empty_state.dart';
import 'package:grocery_shopping_app/presentation/widgets/error_view.dart';
import 'package:grocery_shopping_app/presentation/widgets/product_card.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grocery Shop')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: context.read<ProductProvider>().setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: Selector<ProductProvider, String>(
              selector: (_, provider) => provider.selectedCategory,
              builder: (context, selectedCategory, _) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppCategories.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final category = AppCategories.values[i];
                  return ChoiceChip(
                    label: Text(category),
                    selected: category == selectedCategory,
                    onSelected: (_) =>
                        context.read<ProductProvider>().setCategory(category),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return ErrorView(message: provider.errorMessage!);
                }
                if (provider.products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No products found',
                    subtitle: 'Try a different search or category.',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: provider.products.length,
                  itemBuilder: (context, i) {
                    final product = provider.products[i];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                      onAddToCart: () async {
                        final added = await context
                            .read<CartProvider>()
                            .addToCart(product);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                added ? '${product.name} added to cart' : 'Could not add to cart',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
