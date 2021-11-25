import 'package:note_firebase/domain/core/failures.dart';

class UnexpectedValueError extends Error {
  final ValueFailure valueFailure;
  UnexpectedValueError(this.valueFailure);

  @override
  String toString() =>
      Error.safeToString('UnexpectedValueError(valueFailure: $valueFailure)');
}

class NotAuthenticateError extends Error {}
