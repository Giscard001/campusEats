import 'package:campuseats/core/error/failure.dart';

export 'package:campuseats/core/error/failure.dart';

/// Résultat typé retourné par les repositories (jamais d'exception levée).
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Err<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Err<T>(:final failure) => error(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
