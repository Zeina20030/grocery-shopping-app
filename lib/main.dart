import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shopping_app/core/config/emulator_config.dart';
import 'package:grocery_shopping_app/core/di/service_locator.dart';
import 'package:grocery_shopping_app/core/routing/app_router.dart';
import 'package:grocery_shopping_app/core/theme/app_theme.dart';
import 'package:grocery_shopping_app/firebase_options.dart';
import 'package:grocery_shopping_app/presentation/providers/auth_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/cart_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/order_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/product_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (useFirebaseEmulator) {
    connectToFirebaseEmulators();
  }

  setupServiceLocator();

  runApp(const GroceryShoppingApp());
}

class GroceryShoppingApp extends StatelessWidget {
  const GroceryShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProductProvider>()),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => sl<CartProvider>(),
          update: (_, auth, cart) => cart!..updateUser(auth.currentUser?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => sl<OrderProvider>(),
          update: (_, auth, order) => order!..updateUser(auth.currentUser?.uid),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context.read<AuthProvider>());
          return MaterialApp.router(
            title: 'Grocery Shopping',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
