import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Whether to point Firebase Auth/Firestore at the local Emulator Suite
/// instead of a real cloud project. Defaults to true so the project runs
/// out of the box against `firebase emulators:start` with no cloud project
/// or billing account required. Override at build time for a real backend:
///
///   flutter run --dart-define=USE_FIREBASE_EMULATOR=false
const bool useFirebaseEmulator =
    bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: true);

/// Host that reaches the machine running `firebase emulators:start`.
/// The Android emulator can't resolve "localhost" to the host machine --
/// it needs the special alias 10.0.2.2 -- while web/desktop/iOS simulator
/// all reach the host directly via localhost.
String get _emulatorHost {
  if (kIsWeb) return 'localhost';
  return defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';
}

/// Connects Firestore and Auth to the local emulators. Safe to call once,
/// right after `Firebase.initializeApp()`, before any Firestore/Auth call.
void connectToFirebaseEmulators() {
  FirebaseFirestore.instance.useFirestoreEmulator(_emulatorHost, 8080);
  FirebaseAuth.instance.useAuthEmulator(_emulatorHost, 9099);
}
