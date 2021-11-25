import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:note_firebase/domain/notes/i_note_repository.dart';
import 'package:note_firebase/domain/notes/note.dart';
import 'package:note_firebase/domain/notes/note_failure.dart';

part 'note_actor_event.dart';
part 'note_actor_state.dart';
part 'note_actor_bloc.freezed.dart';

@injectable
class NoteActorBloc extends Bloc<NoteActorEvent, NoteActorState> {
  final INoteRepository _noteRepository;

  NoteActorBloc(this._noteRepository) : super(const _Initial()) {
    on<NoteActorEvent>((event, emit) {
      event.map(
        deleted: (event) => onDeleted(event, emit),
      );
    });
  }

  void onDeleted(_Deleted event, Emitter<NoteActorState> emit) async {
    emit(const NoteActorState.actionInProgress());
    (await _noteRepository.delete(event.note)).fold(
      (f) => emit(NoteActorState.deleteFailure(f)),
      (r) => emit(const NoteActorState.deleteSuccess()),
    );
  }
}
