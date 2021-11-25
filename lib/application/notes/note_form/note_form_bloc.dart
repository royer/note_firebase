import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:note_firebase/domain/notes/i_note_repository.dart';
import 'package:note_firebase/domain/notes/note.dart';
import 'package:note_firebase/domain/notes/note_failure.dart';
import 'package:note_firebase/domain/notes/value_objects.dart';
import 'package:note_firebase/presentation/notes/note_form/misc/todo_item_presentation_classes.dart';

part 'note_form_event.dart';
part 'note_form_state.dart';
part 'note_form_bloc.freezed.dart';

@injectable
class NoteFormBloc extends Bloc<NoteFormEvent, NoteFormState> {
  final INoteRepository _noteRepository;

  NoteFormBloc(this._noteRepository) : super(NoteFormState.initial()) {
    on<NoteFormEvent>((event, emit) {
      event.map(
        initialized: (event) => onInitialized(event, emit),
        bodyChanged: (event) => onNoteBodyChanged(event, emit),
        colorChanged: (event) => onColorChanged(event, emit),
        todosChanged: (event) => onTodosChanged(event, emit),
        saved: (event) => onSaved(event, emit),
      );
    });
  }
  void onInitialized(_Initialized event, Emitter<NoteFormState> emit) async {
    emit(
      event.initNoteOption.fold(
        () => state,
        (initNote) => state.copyWith(
          note: initNote,
          isEditing: true,
        ),
      ),
    );
  }

  void onNoteBodyChanged(_BodyChanged event, Emitter<NoteFormState> emit) {
    emit(
      state.copyWith(
        note: state.note.copyWith(body: NoteBody(event.bodyStr)),
        saveFailureOrSuccessOption: none(), //? why none?
      ),
    );
  }

  void onColorChanged(_ColorChanged event, Emitter<NoteFormState> emit) {
    emit(
      state.copyWith(
        note: state.note.copyWith(color: NoteColor(event.color)),
        saveFailureOrSuccessOption: none(),
      ),
    );
  }

  void onTodosChanged(_TodosChanged event, Emitter<NoteFormState> emit) {
    emit(
      state.copyWith(
        note: state.note.copyWith(
          todos: List3(
              event.todos.map((itemPrimitive) => itemPrimitive.toDomain())),
        ),
        saveFailureOrSuccessOption: none(),
      ),
    );
  }

  void onSaved(_Saved event, Emitter<NoteFormState> emit) async {
    Either<NoteFailure, Unit>? failureOrSuccess;

    emit(state.copyWith(
      isSaving: true,
      saveFailureOrSuccessOption: none(),
    ));

    if (state.note.failureOption.isNone()) {
      failureOrSuccess = state.isEditing
          ? await _noteRepository.update(state.note)
          : await _noteRepository.create(state.note);
    }

    emit(state.copyWith(
      isSaving: false,
      showErrorMessages: true,
      saveFailureOrSuccessOption: optionOf(failureOrSuccess),
    ));
  }
}
