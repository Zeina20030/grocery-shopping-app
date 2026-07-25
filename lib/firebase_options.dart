import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for LOCAL DEVELOPMENT ONLY.
///
/// `demo-grocery-shopping-app` is a Firebase "demo project ID" -- the
/// Local Emulator Suite treats any project ID prefixed with `demo-` as
/// offline-only: no real Firebase/GCP project, billing account, or API
/// keys are involved, and no network calls leave your machine. This is why
/// this file is safe to commit even though it looks like Firebase config.
///
/// To run against a REAL Firebase project instead:
///   1. Run `flutterfire configure` in the project root -- it overwrites
///      this file with your real project's options.
///   2. Run the app with `--dart-define=USE_FIREBASE_EMULATOR=false`.
/// See README.md "Running against a real Firebase project" for details.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const String _projectId = 'demo-grocery-shopping-app';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: _projectId,
    authDomain: '$_projectId.firebaseapp.com',
    storageBucket: '$_projectId.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: _projectId,
    storageBucket: '$_projectId.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: _projectId,
    storageBucket: '$_projectId.appspot.com',
    iosBundleId: 'com.zeina.grocery.groceryShoppingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: _projectId,
    authDomain: '$_projectId.firebaseapp.com',
    storageBucket: '$_projectId.appspot.com',
  );
}
