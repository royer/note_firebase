import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_firebase/domain/auth/i_auth_facade.dart';
import 'package:note_firebase/domain/core/errors.dart';

import '../../injection.dart';

extension FirestoreX on FirebaseFirestore {
  Future<DocumentReference> userDocument() async {
    final userOption = await getIt<IAuthFacade>().getSignedInUser();
    final user = userOption.getOrElse(() => throw NotAuthenticateError());
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid.getOrCrash());
  }
}

extension DocumentReferenceX on DocumentReference {
  CollectionReference get noteCollection => collection('notes');
}
