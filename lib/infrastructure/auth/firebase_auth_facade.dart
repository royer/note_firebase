import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'package:note_firebase/domain/auth/auth_failure.dart';
import 'package:note_firebase/domain/auth/i_auth_facade.dart';
import 'package:note_firebase/domain/auth/user.dart';
import 'package:note_firebase/domain/auth/value_objects.dart';
import 'firebase_user_mapped.dart';

@LazySingleton(as: IAuthFacade)
class FirebaseAuthfacade implements IAuthFacade {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthfacade(
    this._firebaseAuth,
    this._googleSignIn,
  );

  @override
  Future<Option<MyUser>> getSignedInUser() =>
      Future.value(optionOf(_firebaseAuth.currentUser?.toDomain()));

  @override
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword(
      {required EmailAddress email, required Password password}) async {
    final emailaddressStr = email.getOrCrash();
    final passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: emailaddressStr, password: passwordStr);
      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return left(const AuthFailure.emailAlreadyInUse());
      } else {
        return left(const AuthFailure.serverError());
      }
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signWithEmailAndPassword(
      {required EmailAddress email, required Password password}) async {
    final emailaddressStr = email.getOrCrash();
    final passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: emailaddressStr, password: passwordStr);
      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        return left(const AuthFailure.invalidEmailAndPasswordCombination());
      } else {
        return left(const AuthFailure.serverError());
      }
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signWithGoogle() async {
    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        return left(const AuthFailure.cancelledByUser());
      }

      final googleAuth = await googleAccount.authentication;
      final authCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      return _firebaseAuth
          .signInWithCredential(authCredential)
          .then((value) => right(unit));
    } on Exception catch (_) {
      return left(const AuthFailure.serverError());
    }
  }

  @override
  Future<void> signOut() async => Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
}
