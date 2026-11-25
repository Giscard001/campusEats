import 'package:equatable/equatable.dart';

class Scholar extends Equatable {
  const Scholar({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.matricule,
  });

  final String id;
  final String lastName;
  final String firstName;
  final String matricule;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, lastName, firstName, matricule];
}

class PendingAccount extends Equatable {
  const PendingAccount({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.matricule,
    this.className,
    this.candidate,
  });

  final String id;
  final String lastName;
  final String firstName;
  final String matricule;
  final String? className;
  final Scholar? candidate;

  String get fullName => '$firstName $lastName';
  bool get hasCandidateMatch => candidate != null;

  @override
  List<Object?> get props => [id, lastName, firstName, matricule, className, candidate];
}

class ImportLineError extends Equatable {
  const ImportLineError({required this.line, required this.message});
  final int line;
  final String message;

  @override
  List<Object?> get props => [line, message];
}

class ImportResult extends Equatable {
  const ImportResult({
    required this.added,
    required this.duplicates,
    required this.errors,
  });

  final int added;
  final int duplicates;
  final List<ImportLineError> errors;

  @override
  List<Object?> get props => [added, duplicates, errors];
}
