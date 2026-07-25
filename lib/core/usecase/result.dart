import 'package:grocery_shopping_app/core/error/failures.dart';

/// A minimal Success/Error result type for one-shot operations (sign in,
/// place an order, ...). Real-time data instead flows through `Stream`s
/// directly, since that maps naturally onto Firestore's `.snapshots()`.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.error(Failure failure) = Error<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Error<T>) return error(self.failure);
    throw StateError('Unreachable');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
