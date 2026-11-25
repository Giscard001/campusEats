import 'package:equatable/equatable.dart';

/// Représente une erreur métier ou technique normalisée à la frontière data.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Connexion impossible. Vérifiez votre réseau et réessayez.',
  ]);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Votre session a expiré. Veuillez vous reconnecter.',
  ]);
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = "Vous n'avez pas l'autorisation d'effectuer cette action.",
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'Élément introuvable.',
  ]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

final class ConflictFailure extends Failure {
  const ConflictFailure(
    this.code,
    super.message, {
    this.details = const {},
  });

  final String code;
  final Map<String, dynamic> details;

  @override
  List<Object?> get props => [code, message, details];
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Une erreur serveur est survenue. Réessayez plus tard.',
  ]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Une erreur inattendue est survenue.',
  ]);
}
