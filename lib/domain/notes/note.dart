import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:note_firebase/domain/core/failures.dart';
import 'package:note_firebase/domain/core/value_objects.dart';
import 'package:note_firebase/domain/notes/todo_item.dart';
import 'package:note_firebase/domain/notes/value_objects.dart';

part 'note.freezed.dart';

//TODO need to deep learning:
//     the way add custom method to freezed class is XXXX
//     refrence freezed document [https://pub.dev/packages/freezed#custom-getters-and-methods]
//

@freezed
class Note with _$Note {
  const Note._();
  const factory Note({
    required UniqueId id,
    required NoteBody body,
    required NoteColor color,
    required List3<TodoItem> todos,
  }) = _Note;

  factory Note.empty() => Note(
        id: UniqueId(),
        body: NoteBody(''),
        color: NoteColor(NoteColor.predefinedColors[0]),
        todos: List3(emptyList()),
      );

  Option<ValueFailure<dynamic>> get failureOption {
    return body.failureOrUnit
        .andThen(todos.failureOrUnit)
        .andThen(
            //TODO  TO UNDERSTAND THIS CRIZY CHAIN!!!
            //
            todos
                .getOrCrash() // return KtList<TodoItem>
                // getting the failureOption of the each TodoItem
                .map((todoitem) => todoitem.failureOption)
                // only get the failure items. because failureOption is a Option class.
                // it means failure is some.
                .filter((o) => o.isSome())
                // If we can't get the 0th element, the list is empty. In such a case, it's valid.
                .getOrElse(0, (_) => none())
                .fold(() => right(unit), (a) => left(a)))
        .fold(
          (l) => some(l),
          (r) => none(),
        );
  }
}
