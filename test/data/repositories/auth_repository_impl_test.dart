import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:grocery_shopping_app/data/repositories/auth_repository_impl.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore firestore;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    repository = AuthRepositoryImpl(FirebaseAuthDataSource(mockAuth, firestore));
  });

  test('starts signed out', () {
    expect(repository.currentUser, isNull);
  });

  test('signUp creates an account, mirrors the profile to Firestore, and signs in', () async {
    final result = await repository.signUp(
      email: 'shopper@example.com',
      password: 'secret1',
      displayName: 'Alex Shopper',
    );

    expect(result, isA<Success>());
    final user = (result as Success).data;
    expect(user.email, 'shopper@example.com');
    expect(user.displayName, 'Alex Shopper');
    expect(repository.currentUser, isNotNull);

    final profileDoc = await firestore.collection('users').doc(user.uid).get();
    expect(profileDoc.data()?['displayName'], 'Alex Shopper');
  });

  test('authStateChanges reflects sign in and sign out', () async {
    final states = <bool>[];
    final subscription =
        repository.authStateChanges.listen((user) => states.add(user != null));

    await Future<void>.delayed(Duration.zero);
    await repository.signUp(
      email: 'a@b.com',
      password: 'secret1',
      displayName: 'A',
    );
    await repository.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(states, [false, true, false]);
    await subscription.cancel();
  });
}
