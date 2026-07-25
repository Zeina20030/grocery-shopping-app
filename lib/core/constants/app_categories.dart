/// Product categories used for catalog filtering. Kept as a simple constant
/// list (rather than an enum) so new categories can be added to Firestore
/// data without a code change.
class AppCategories {
  const AppCategories._();

  static const String all = 'All';

  static const List<String> values = [
    all,
    'Fruits & Vegetables',
    'Dairy & Eggs',
    'Bakery',
    'Meat & Seafood',
    'Pantry',
    'Beverages',
    'Snacks',
    'Frozen',
    'Household',
  ];
}
