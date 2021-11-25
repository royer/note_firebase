import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_firebase/application/notes/note_form/note_form_bloc.dart';
import 'package:note_firebase/domain/notes/note.dart';
import 'package:note_firebase/presentation/notes/note_form/widgets/body_field_widget.dart';
import 'package:note_firebase/presentation/routes/router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:auto_route/auto_route.dart';

import '../../../injection.dart';

class NoteFormPage extends StatelessWidget {
  final Note? editedNote;

  const NoteFormPage({
    required this.editedNote,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NoteFormBloc>()
        ..add(NoteFormEvent.initialized(optionOf(editedNote))),
      child: BlocConsumer<NoteFormBloc, NoteFormState>(
        listener: (context, state) {
          state.saveFailureOrSuccessOption.fold(
            () {},
            (either) {
              either.fold(
                (f) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(f.map(
                      unexpected: (_) => 'unexpected',
                      insufficientPermission: (_) => 'insufficientPermission',
                      unableToUpdate: (_) => 'unableToUpdate',
                    )),
                  ));
                },
                (r) => context.router.popUntil(
                  (route) => route.settings.name == NotesOverviewRoute.name,
                ),
              );
            },
          );
        },
        buildWhen: (p, c) => p.isSaving != c.isSaving,
        builder: (context, state) {
          return Stack(
            children: [
              const _NoteFormPageScaffold(),
              _SavingInprogressOverlay(
                isSaving: state.isSaving,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SavingInprogressOverlay extends StatelessWidget {
  final bool isSaving;

  const _SavingInprogressOverlay({
    required this.isSaving,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isSaving,
      child: AnimatedContainer(
        color: isSaving ? Colors.black.withOpacity(0.8) : Colors.transparent,
        duration: const Duration(milliseconds: 150),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Visibility(
          visible: isSaving,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Saving',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteFormPageScaffold extends StatelessWidget {
  const _NoteFormPageScaffold({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NoteFormBloc, NoteFormState>(
          buildWhen: (p, c) => p.isEditing != c.isEditing,
          builder: (context, state) {
            return Text(state.isEditing ? 'Edit a note' : 'Create a note');
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NoteFormBloc>().add(const NoteFormEvent.saved());
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: BlocBuilder<NoteFormBloc, NoteFormState>(
        buildWhen: (p, c) => p.showErrorMessages != c.showErrorMessages,
        builder: (context, state) {
          return Form(
            autovalidateMode: state.showErrorMessages
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const BodyField(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
