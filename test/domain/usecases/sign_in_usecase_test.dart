import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_app/core/error/failures.dart';
import 'package:grocery_shopping_app/core/usecase/result.dart';
import 'package:grocery_shopping_app/domain/entities/app_user.dart';
import 'package:grocery_shopping_app/domain/repositories/auth_repository.dart';
import 'package:grocery_shopping_app/domain/usecases/auth/sign_in_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  bool signInCalled = false;

  @override
  Future<Result<AppUser>> signIn({required String email, required String password}) async {
    signInCalled = true;
    return const Result.success(
      AppUser(uid: 'u1', email: 'a@b.com', displayName: 'A'),
    );
  }

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  AppUser? get currentUser => null;

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

void main() {
  late _FakeAuthRepository repository;
  late SignInUseCase useCase;

  setUp(() {
    repository = _FakeAuthRepository();
    useCase = SignInUseCase(repository);
  });

  test('rejects an invalid email without calling the repository', () async {
    final result = await useCase((email: 'not-an-email', password: 'secret1'));

    expect(result, isA<Error<AppUser>>());
    expect((result as Error<AppUser>).failure, isA<ValidationFailure>());
    expect(repository.signInCalled, isFalse);
  });

  test('rejects an empty password without calling the repository', () async {
    final result = await useCase((email: 'a@b.com', password: ''));

    expect(result, isA<Error<AppUser>>());
    expect(repository.signInCalled, isFalse);
  });

  test('delegates to the repository for valid input', () async {
    final result = await useCase((email: 'a@b.com', password: 'secret1'));

    expect(repository.signInCalled, isTrue);
    expect(result, isA<Success<AppUser>>());
  });
}
