import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/kt.dart';
import 'package:note_firebase/domain/notes/i_note_repository.dart';
import 'package:note_firebase/domain/notes/note.dart';
import 'package:note_firebase/domain/notes/note_failure.dart';

part 'note_watcher_event.dart';
part 'note_watcher_state.dart';
part 'note_watcher_bloc.freezed.dart';

@injectable
class NoteWatcherBloc extends Bloc<NoteWatcherEvent, NoteWatcherState> {
  final INoteRepository _noteRepository;

  StreamSubscription<Either<NoteFailure, KtList<Note>>>?
      _noteStreamSubscription;

  NoteWatcherBloc(this._noteRepository) : super(const _Initial()) {
    on<NoteWatcherEvent>((event, emit) {
      event.map(
        watchAllStarted: (event) => onWatchAllStarted(event, emit),
        watchUncompletedStarted: (event) =>
            onWatchUncompletedStarted(event, emit),
        notesReceived: (event) => onNotesReceived(event, emit),
      );
    });
  }

  void onNotesReceived(_NotesReceived event, Emitter<NoteWatcherState> emit) {
    return emit(
      event.failureOrNotes.fold(
        (f) => NoteWatcherState.loadFailure(f),
        (notes) => NoteWatcherState.loadSuccess(notes),
      ),
    );
  }

  void onWatchAllStarted(
      _WatchAllStarted event, Emitter<NoteWatcherState> emit) async {
    emit(const NoteWatcherState.loadInProgress());
    await _noteStreamSubscription?.cancel();

    _noteStreamSubscription = _noteRepository.watchAll().listen(
        (failureOrNotes) =>
            add(NoteWatcherEvent.notesReceived(failureOrNotes)));
  }

  void onWatchUncompletedStarted(
      _WatchUncompletedStarted event, Emitter<NoteWatcherState> emit) async {
    emit(const NoteWatcherState.loadInProgress());
    await _noteStreamSubscription?.cancel();
    _noteStreamSubscription = _noteRepository.watchUncompleted().listen(
        (failureOrNotes) =>
            add(NoteWatcherEvent.notesReceived(failureOrNotes)));
  }

  @override
  Future<void> close() async {
    await _noteStreamSubscription?.cancel();

    return super.close();
  }
}
