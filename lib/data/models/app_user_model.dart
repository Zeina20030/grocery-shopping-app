import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:grocery_shopping_app/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    required super.displayName,
  });

  factory AppUserModel.fromFirebaseUser(fb.User user) => AppUserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName:
            (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!
                : (user.email ?? 'Shopper'),
      );
}
