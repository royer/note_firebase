import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_firebase/application/notes/note_watcher/note_watcher_bloc.dart';
import 'package:note_firebase/presentation/notes/notes_overview/widgets/error_note_card_widget.dart';
import 'package:note_firebase/presentation/notes/notes_overview/widgets/note_card_widget.dart';

class NotesOverviewBody extends StatelessWidget {
  const NotesOverviewBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteWatcherBloc, NoteWatcherState>(
      builder: (context, state) {
        return state.map(
          initial: (initial) => Container(),
          loadInProgress: (loadInProgress) => const Center(
            child: CircularProgressIndicator(),
          ),
          loadSuccess: (lSState) {
            return ListView.builder(
              itemBuilder: (context, index) {
                final note = lSState.notes[index];
                if (note.failureOption.isSome()) {
                  // there is failure in this note
                  return ErrorNoteCard(note: note);
                } else {
                  return NoteCard(
                    note: note,
                  );
                }
              },
              itemCount: lSState.notes.size,
            );
          },
          loadFailure: (lfState) {
            return Container(
                color: Colors.amber,
                child: const Center(child: Text('failure')));
          },
        );
      },
    );
  }
}
