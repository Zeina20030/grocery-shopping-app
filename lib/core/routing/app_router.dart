import 'package:go_router/go_router.dart';
import 'package:grocery_shopping_app/presentation/providers/auth_provider.dart';
import 'package:grocery_shopping_app/presentation/screens/auth/login_screen.dart';
import 'package:grocery_shopping_app/presentation/screens/auth/signup_screen.dart';
import 'package:grocery_shopping_app/presentation/screens/catalog/product_detail_screen.dart';
import 'package:grocery_shopping_app/presentation/screens/home/home_screen.dart';
import 'package:grocery_shopping_app/presentation/screens/splash/splash_screen.dart';

/// Declarative routing with an auth gate: unauthenticated users are always
/// redirected to /login, authenticated users away from /login, /signup, and
/// the splash route. [authProvider] is passed as `refreshListenable` so the
/// router re-evaluates redirects the instant auth state changes.
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/signup';

      if (status == AuthStatus.unknown) {
        return location == '/' ? null : '/';
      }
      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }
      // authenticated
      if (isAuthRoute || location == '/') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
    ],
  );
}
