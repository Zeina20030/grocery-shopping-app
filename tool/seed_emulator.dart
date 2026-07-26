// Seeds the local Firestore emulator with a small demo product catalog so
// the app has something to display when run against
// `firebase emulators:start`. This is sample catalog data for local
// development only -- not real inventory, pricing, or user data.
//
// Usage (with the emulator already running):
//   dart run tool/seed_emulator.dart
import 'dart:convert';
import 'dart:io';

const String _projectId = 'demo-grocery-shopping-app';
const String _emulatorHost = 'localhost:8080';

final List<Map<String, Object>> _demoProducts = [
  {
    'id': 'bananas',
    'name': 'Bananas',
    'description': 'Fresh bunch of ripe bananas, sold by the pound.',
    'price': 0.59,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Bananas_on_black_background_02.jpg/500px-Bananas_on_black_background_02.jpg',
    'category': 'Fruits & Vegetables',
    'unit': 'lb',
    'stock': 150,
  },
  {
    'id': 'roma-tomatoes',
    'name': 'Roma Tomatoes',
    'description': 'Firm, flavorful tomatoes great for sauces and salads.',
    'price': 1.29,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Roma_Tomatoes_%2853512765752%29.jpg/500px-Roma_Tomatoes_%2853512765752%29.jpg',
    'category': 'Fruits & Vegetables',
    'unit': 'lb',
    'stock': 90,
  },
  {
    'id': 'whole-milk',
    'name': 'Whole Milk',
    'description': 'Vitamin D whole milk, half-gallon carton.',
    'price': 3.49,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Cookies_and_milk.jpg/500px-Cookies_and_milk.jpg',
    'category': 'Dairy & Eggs',
    'unit': 'half-gallon',
    'stock': 60,
  },
  {
    'id': 'large-eggs',
    'name': 'Large Eggs',
    'description': 'Grade A large eggs, dozen.',
    'price': 4.19,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/6-Pack-Chicken-Eggs.jpg/500px-6-Pack-Chicken-Eggs.jpg',
    'category': 'Dairy & Eggs',
    'unit': 'dozen',
    'stock': 80,
  },
  {
    'id': 'sourdough-loaf',
    'name': 'Sourdough Loaf',
    'description': 'Freshly baked sourdough bread.',
    'price': 5.99,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Sourdough_Bread_Loaf.jpg/500px-Sourdough_Bread_Loaf.jpg',
    'category': 'Bakery',
    'unit': 'loaf',
    'stock': 25,
  },
  {
    'id': 'chicken-breast',
    'name': 'Chicken Breast',
    'description': 'Boneless, skinless chicken breast.',
    'price': 6.49,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Raw_chicken_slices.jpg/500px-Raw_chicken_slices.jpg',
    'category': 'Meat & Seafood',
    'unit': 'lb',
    'stock': 40,
  },
  {
    'id': 'atlantic-salmon',
    'name': 'Atlantic Salmon Fillet',
    'description': 'Fresh salmon fillet, skin-on.',
    'price': 9.99,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Salmon2.jpg/500px-Salmon2.jpg',
    'category': 'Meat & Seafood',
    'unit': 'lb',
    'stock': 20,
  },
  {
    'id': 'jasmine-rice',
    'name': 'Jasmine Rice',
    'description': 'Fragrant long-grain jasmine rice, 5 lb bag.',
    'price': 7.99,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Mushqbudji_rice_grains_close-up.jpg/500px-Mushqbudji_rice_grains_close-up.jpg',
    'category': 'Pantry',
    'unit': '5 lb bag',
    'stock': 70,
  },
  {
    'id': 'olive-oil',
    'name': 'Extra Virgin Olive Oil',
    'description': 'Cold-pressed extra virgin olive oil, 500ml.',
    'price': 8.49,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Olive_oil_bottle_Bertolli_Riserva_Premium.jpg/500px-Olive_oil_bottle_Bertolli_Riserva_Premium.jpg',
    'category': 'Pantry',
    'unit': '500ml',
    'stock': 55,
  },
  {
    'id': 'orange-juice',
    'name': 'Orange Juice',
    'description': 'No pulp, 100% orange juice, 52 fl oz.',
    'price': 4.79,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Orange_juice_1_edit1.jpg/500px-Orange_juice_1_edit1.jpg',
    'category': 'Beverages',
    'unit': '52 fl oz',
    'stock': 45,
  },
  {
    'id': 'sparkling-water',
    'name': 'Sparkling Water 12-pack',
    'description': 'Unsweetened sparkling water, 12 cans.',
    'price': 5.49,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Sparkling_water_at_sunrise_-_Massachusetts.jpg/500px-Sparkling_water_at_sunrise_-_Massachusetts.jpg',
    'category': 'Beverages',
    'unit': '12-pack',
    'stock': 65,
  },
  {
    'id': 'tortilla-chips',
    'name': 'Tortilla Chips',
    'description': 'Crunchy corn tortilla chips, family size.',
    'price': 3.99,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Corn_chips_close_up.jpg/500px-Corn_chips_close_up.jpg',
    'category': 'Snacks',
    'unit': '13 oz bag',
    'stock': 85,
  },
  {
    'id': 'mixed-nuts',
    'name': 'Mixed Nuts',
    'description': 'Roasted and salted mixed nuts.',
    'price': 6.99,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Mixed_nuts_bowl.jpg/500px-Mixed_nuts_bowl.jpg',
    'category': 'Snacks',
    'unit': '10 oz can',
    'stock': 50,
  },
  {
    'id': 'frozen-blueberries',
    'name': 'Frozen Blueberries',
    'description': 'Individually quick-frozen blueberries.',
    'price': 4.49,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Blueberries_in_a_little_bowl.jpg/500px-Blueberries_in_a_little_bowl.jpg',
    'category': 'Frozen',
    'unit': '16 oz bag',
    'stock': 35,
  },
  {
    'id': 'vanilla-ice-cream',
    'name': 'Vanilla Ice Cream',
    'description': 'Classic vanilla bean ice cream.',
    'price': 5.29,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Bowl_~_Ice_cream.jpg/500px-Bowl_~_Ice_cream.jpg',
    'category': 'Frozen',
    'unit': '1.5 qt',
    'stock': 0,
  },
  {
    'id': 'paper-towels',
    'name': 'Paper Towels 6-pack',
    'description': 'Absorbent paper towels, 6 double rolls.',
    'price': 9.49,
    'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Roll_of_Paper_Towels.jpg/500px-Roll_of_Paper_Towels.jpg',
    'category': 'Household',
    'unit': '6-pack',
    'stock': 100,
  },
];

Object _encodeField(Object value) {
  if (value is String) return {'stringValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value};
  throw ArgumentError('Unsupported field type: ${value.runtimeType}');
}

Future<void> main() async {
  final client = HttpClient();
  var seeded = 0;

  for (final product in _demoProducts) {
    final id = product['id'] as String;
    final fields = {
      for (final entry in product.entries)
        if (entry.key != 'id') entry.key: _encodeField(entry.value),
    };

    final uri = Uri.http(
      _emulatorHost,
      '/v1/projects/$_projectId/databases/(default)/documents/products/$id',
    );

    final request = await client.patchUrl(uri);
    request.headers.contentType = ContentType.json;
    // The Firestore emulator (like production) enforces firestore.rules,
    // which intentionally block client writes to /products (catalog writes
    // belong to a trusted admin/back office). "Bearer owner" is the
    // emulator's documented admin-bypass token for exactly this seeding
    // use case -- it has no effect against a real Firebase project.
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
    request.write(jsonEncode({'fields': fields}));
    final response = await request.close();
    await response.drain<void>();

    if (response.statusCode == 200) {
      seeded++;
    } else {
      stderr.writeln('Failed to seed "$id": HTTP ${response.statusCode}');
    }
  }

  client.close();
  stdout.writeln('Seeded $seeded/${_demoProducts.length} demo products into '
      'the Firestore emulator ($_emulatorHost).');
}
