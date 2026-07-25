import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shopping_app/domain/entities/cart_item.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.name,
    required super.price,
    required super.imageUrl,
    required super.unit,
    required super.quantity,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return CartItemModel(
      productId: doc.id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      unit: data['unit'] as String? ?? 'each',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  factory CartItemModel.fromProduct(Product product, int quantity) => CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        unit: product.unit,
        quantity: quantity,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'unit': unit,
        'quantity': quantity,
      };
}
