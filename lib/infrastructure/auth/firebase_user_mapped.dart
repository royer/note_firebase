import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_firebase/domain/auth/user.dart';
import 'package:note_firebase/domain/core/value_objects.dart';

extension FirebaseUserDomainX on User {
  MyUser toDomain() {
    return MyUser(uid: UniqueId.fromUniqueString(uid));
  }
}
