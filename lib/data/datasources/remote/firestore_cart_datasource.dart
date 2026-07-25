import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shopping_app/core/constants/firestore_paths.dart';
import 'package:grocery_shopping_app/data/models/cart_item_model.dart';
import 'package:grocery_shopping_app/domain/entities/product.dart';

class FirestoreCartDataSource {
  final FirebaseFirestore _firestore;

  const FirestoreCartDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _firestore.collection(FirestorePaths.cartItems(uid));

  Stream<List<CartItemModel>> watchCart(String uid) {
    return _items(uid).snapshots().map(
          (snapshot) => snapshot.docs.map(CartItemModel.fromFirestore).toList(),
        );
  }

  Future<void> addToCart(String uid, Product product, int quantity) async {
    final ref = _items(uid).doc(product.id);
    final existing = await ref.get();

    if (existing.exists) {
      final currentQty = (existing.data()?['quantity'] as num?)?.toInt() ?? 0;
      await ref.update({'quantity': currentQty + quantity});
    } else {
      await ref.set(CartItemModel.fromProduct(product, quantity).toMap());
    }
  }

  Future<void> updateQuantity(String uid, String productId, int quantity) {
    return _items(uid).doc(productId).update({'quantity': quantity});
  }

  Future<void> removeFromCart(String uid, String productId) {
    return _items(uid).doc(productId).delete();
  }

  Future<void> clearCart(String uid) async {
    final snapshot = await _items(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
