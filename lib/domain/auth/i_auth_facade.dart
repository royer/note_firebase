import 'package:dartz/dartz.dart';
import 'package:note_firebase/domain/auth/auth_failure.dart';
import 'package:note_firebase/domain/auth/user.dart';
import 'package:note_firebase/domain/auth/value_objects.dart';

abstract class IAuthFacade {
  Future<Option<MyUser>> getSignedInUser();
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword({
    required EmailAddress email,
    required Password password,
  });
  Future<Either<AuthFailure, Unit>> signWithEmailAndPassword({
    required EmailAddress email,
    required Password password,
  });
  Future<Either<AuthFailure, Unit>> signWithGoogle();
  Future<void> signOut();
}
