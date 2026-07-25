/// Base contract for a one-shot use case: takes [Params] and asynchronously
/// returns a [Type] (typically a `Result<T>`, sometimes `void`).
abstract interface class UseCase<ReturnType, Params> {
  Future<ReturnType> call(Params params);
}

/// Marker for use cases that take no parameters.
class NoParams {
  const NoParams();
}
