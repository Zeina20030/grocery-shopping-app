/// Centralized Firestore collection/document path builders so the exact
/// schema lives in one place instead of being repeated as magic strings
/// across every datasource.
class FirestorePaths {
  const FirestorePaths._();

  static const String products = 'products';
  static const String users = 'users';
  static const String orders = 'orders';

  /// carts/{uid}/items/{productId} -- per-user subcollection so cart reads
  /// and Firestore security rules are naturally scoped to the owning user.
  static String cartItems(String uid) => 'carts/$uid/items';
}
