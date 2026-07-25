import 'package:equatable/equatable.dart';

/// Base type for anything that can go wrong in the domain/data layers.
/// Kept deliberately small -- each variant maps to a distinct, user-facing
/// situation rather than mirroring every possible exception type.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
