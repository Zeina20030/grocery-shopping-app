import 'package:equatable/equatable.dart';

/// A line in the current user's cart. Denormalizes the product's name,
/// price, and image at the time it was added so the cart still renders
/// sensibly even if the product document later changes or is removed.
class CartItem extends Equatable {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final String unit;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.unit,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        unit: unit,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [productId, name, price, imageUrl, unit, quantity];
}
