import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grocery_shopping_app/core/constants/app_categories.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';
import 'package:grocery_shopping_app/domain/repositories/product_repository.dart';

/// Real-time product catalog. Re-subscribes to Firestore whenever the
/// category filter changes; search is applied client-side over whatever
/// the current stream holds.
class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  StreamSubscription<List<Product>>? _subscription;

  List<Product> _products = [];
  String _selectedCategory = AppCategories.all;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;

  ProductProvider({required ProductRepository productRepository})
      : _productRepository = productRepository {
    _subscribe();
  }

  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Product> get products {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void setCategory(String category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    _subscribe();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void _subscribe() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _productRepository
        .watchProducts(category: _selectedCategory)
        .listen(
      (products) {
        _products = products;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Could not load products. Please try again.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
