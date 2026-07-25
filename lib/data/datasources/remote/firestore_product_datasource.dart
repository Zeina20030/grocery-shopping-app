import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shopping_app/core/constants/app_categories.dart';
import 'package:grocery_shopping_app/core/constants/firestore_paths.dart';
import 'package:grocery_shopping_app/data/models/product_model.dart';

class FirestoreProductDataSource {
  final FirebaseFirestore _firestore;

  const FirestoreProductDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(FirestorePaths.products);

  Stream<List<ProductModel>> watchProducts({String? category}) {
    Query<Map<String, dynamic>> query = _products.orderBy('name');
    if (category != null && category != AppCategories.all) {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(ProductModel.fromFirestore).toList(),
        );
  }

  Stream<ProductModel?> watchProductById(String productId) {
    return _products.doc(productId).snapshots().map(
          (doc) => doc.exists ? ProductModel.fromFirestore(doc) : null,
        );
  }
}
