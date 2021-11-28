import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:note_firebase/application/notes/note_form/note_form_bloc.dart';
import 'package:note_firebase/domain/notes/value_objects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BodyField extends HookWidget {
  const BodyField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textEditControll = useTextEditingController();
    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (p, c) => p.isEditing != c.isEditing,
      listener: (context, state) {
        textEditControll.text = state.note.body.getOrCrash();
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: TextFormField(
          controller: textEditControll,
          decoration: const InputDecoration(
            labelText: 'Note',
            counterText: '',
          ),
          maxLength: NoteBody.maxLength,
          maxLines: null,
          minLines: 5,
          onChanged: (value) => context
              .read<NoteFormBloc>()
              .add(NoteFormEvent.bodyChanged(value)),
          validator: (_) =>
              context.read<NoteFormBloc>().state.note.body.value.fold(
                    (f) => f.maybeMap(
                      empty: (f) => 'Can not empty',
                      exceedingLength: (f) => 'Exceeding length. max: ${f.max}',
                      orElse: () => null,
                    ),
                    (r) => null,
                  ),
        ),
      ),
    );
  }
}
