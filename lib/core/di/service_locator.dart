import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:get_it/get_it.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firestore_cart_datasource.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firestore_order_datasource.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firestore_product_datasource.dart';
import 'package:grocery_shopping_app/data/repositories/auth_repository_impl.dart';
import 'package:grocery_shopping_app/data/repositories/cart_repository_impl.dart';
import 'package:grocery_shopping_app/data/repositories/order_repository_impl.dart';
import 'package:grocery_shopping_app/data/repositories/product_repository_impl.dart';
import 'package:grocery_shopping_app/domain/repositories/auth_repository.dart';
import 'package:grocery_shopping_app/domain/repositories/cart_repository.dart';
import 'package:grocery_shopping_app/domain/repositories/order_repository.dart';
import 'package:grocery_shopping_app/domain/repositories/product_repository.dart';
import 'package:grocery_shopping_app/domain/usecases/auth/sign_in_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/auth/sign_out_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/auth/sign_up_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/add_to_cart_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/clear_cart_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/remove_from_cart_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/cart/update_cart_quantity_usecase.dart';
import 'package:grocery_shopping_app/domain/usecases/order/place_order_usecase.dart';
import 'package:grocery_shopping_app/presentation/providers/auth_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/cart_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/order_provider.dart';
import 'package:grocery_shopping_app/presentation/providers/product_provider.dart';

final GetIt sl = GetIt.instance;

/// Wires every layer together: Firebase SDKs -> datasources -> repositories
/// -> use cases -> presentation providers. Call once during app startup,
/// after `Firebase.initializeApp()`.
void setupServiceLocator() {
  // Firebase SDK instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Datasources
  sl.registerLazySingleton(() => FirebaseAuthDataSource(sl(), sl()));
  sl.registerLazySingleton(() => FirestoreProductDataSource(sl()));
  sl.registerLazySingleton(() => FirestoreCartDataSource(sl()));
  sl.registerLazySingleton(() => FirestoreOrderDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(sl()));
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantityUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerLazySingleton(() => PlaceOrderUseCase(sl(), sl()));

  // Presentation providers -- registered as factories so each is created
  // fresh by the widget tree's MultiProvider, but built from the same
  // singleton use cases/repositories above.
  sl.registerFactory(() => AuthProvider(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        authRepository: sl(),
      ));
  sl.registerFactory(() => ProductProvider(productRepository: sl()));
  sl.registerFactory(() => CartProvider(
        cartRepository: sl(),
        addToCartUseCase: sl(),
        updateCartQuantityUseCase: sl(),
        removeFromCartUseCase: sl(),
        clearCartUseCase: sl(),
      ));
  sl.registerFactory(() => OrderProvider(
        orderRepository: sl(),
        placeOrderUseCase: sl(),
      ));
}
