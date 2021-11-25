import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/kt.dart';
import 'package:dartz/dartz.dart';
import 'package:note_firebase/domain/notes/i_note_repository.dart';
import 'package:note_firebase/domain/notes/note_failure.dart';
import 'package:note_firebase/domain/notes/note.dart';
import 'package:note_firebase/infrastructure/core/firestore_helpers.dart';
import 'package:note_firebase/infrastructure/notes/note_dtos.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: INoteRepository)
class NoteRepository implements INoteRepository {
  final FirebaseFirestore _firestore;

  NoteRepository(this._firestore);

  //TODO learn dart: how to return a Stream object.
  //TODO learn rxdart package.
  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchAll() async* {
    //users/{userid}/notes/{noteid}/
    final DocumentReference userdoc = await _firestore.userDocument();
    yield* userdoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => right<NoteFailure, KtList<Note>>(
            snapshot.docs
                .map((doc) => NoteDto.fromFriestore(doc).toDomain())
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((error, stackTrace) {
      if (error is PlatformException &&
          error.message!.contains('PERMISSION_DENIED')) {
        return left(
          const NoteFailure.insufficientPermission(),
        );
      } else {
        log('get unexpected error on get all notes. error: $error');
        return left(const NoteFailure.unexpected());
      }
    });
  }

  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchUncompleted() async* {
    final DocumentReference userdoc = await _firestore.userDocument();
    yield* userdoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => NoteDto.fromFriestore(doc).toDomain()),
        )
        .map(
          (notes) => right<NoteFailure, KtList<Note>>(
            notes
                .where(
                  (note) =>
                      note.todos.getOrCrash().any((todoItem) => !todoItem.done),
                )
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((error, stackTrace) {
      if (error is PlatformException &&
          error.message!.contains('PERMISSION_DENIED')) {
        return left(
          const NoteFailure.insufficientPermission(),
        );
      } else {
        log('get unexpected error on get all notes. error: $error');
        return left(const NoteFailure.unexpected());
      }
    });
  }

  @override
  Future<Either<NoteFailure, Unit>> create(Note note) async {
    try {
      final userdoc = await _firestore.userDocument();
      final noteDto = NoteDto.fromDomain(note);
      await userdoc.noteCollection.doc(noteDto.id).set(noteDto.toJson());
      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return left(const NoteFailure.insufficientPermission());
      } else {
        return left(const NoteFailure.unexpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> update(Note note) async {
    try {
      final userdoc = await _firestore.userDocument();
      final noteDto = NoteDto.fromDomain(note);
      await userdoc.noteCollection.doc(noteDto.id).update(noteDto.toJson());
      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return left(const NoteFailure.insufficientPermission());
      } else if (e.code == 'NOT_FOUND') {
        return left(const NoteFailure.unableToUpdate());
      } else {
        return left(const NoteFailure.unexpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> delete(Note note) async {
    try {
      final userdoc = await _firestore.userDocument();
      final noteId = note.id.getOrCrash();
      await userdoc.noteCollection.doc(noteId).delete();
      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return left(const NoteFailure.insufficientPermission());
      } else {
        return left(const NoteFailure.unexpected());
      }
    }
  }
}
