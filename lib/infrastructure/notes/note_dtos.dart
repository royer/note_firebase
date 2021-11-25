import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/kt.dart';
import 'package:note_firebase/domain/core/value_objects.dart';
import 'package:note_firebase/domain/notes/note.dart';
import 'package:note_firebase/domain/notes/todo_item.dart';
import 'package:note_firebase/domain/notes/value_objects.dart';

part 'note_dtos.freezed.dart';
part 'note_dtos.g.dart';

@freezed
//@JsonSerializable() freezed automaticly generate fromJson/toJson when you dev_dependency has
// json_serializable
class TodoItemDto with _$TodoItemDto {
  const TodoItemDto._();
  const factory TodoItemDto({
    required String id,
    required String name,
    required bool done,
  }) = _TodoItemDto;

  factory TodoItemDto.fromDomain(TodoItem todoItem) {
    return TodoItemDto(
      id: todoItem.id.getOrCrash(),
      name: todoItem.name.getOrCrash(),
      done: todoItem.done,
    );
  }

  TodoItem toDomain() {
    return TodoItem(
      id: UniqueId.fromUniqueString(id),
      name: TodoName(name),
      done: done,
    );
  }

  factory TodoItemDto.fromJson(Map<String, dynamic> json) =>
      _$TodoItemDtoFromJson(json);

  //Map<String, dynamic> toJson() => _$TodoItemDtoToJson(this);
}

@freezed
class NoteDto with _$NoteDto {
  const NoteDto._();
  const factory NoteDto({
    @JsonKey(ignore: true) @Default('') String id,
    required String body,
    required int color,
    required List<TodoItemDto> todos,
    @_ServerTimestampConverter() required FieldValue serverTimeStamp,
  }) = _NoteDto;

  factory NoteDto.fromDomain(Note note) {
    return NoteDto(
      id: note.id.getOrCrash(),
      body: note.body.getOrCrash(),
      color: note.color.getOrCrash().value,
      todos: note.todos
          .getOrCrash()
          .map((item) => TodoItemDto.fromDomain(item))
          .asList(),
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  Note toDomain() {
    return Note(
      id: UniqueId.fromUniqueString(id),
      body: NoteBody(body),
      color: NoteColor(Color(color)),
      todos: List3(todos.map((e) => e.toDomain()).toImmutableList()),
    );
  }

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);

  factory NoteDto.fromFriestore(DocumentSnapshot doc) {
    return NoteDto.fromJson(doc.data() as Map<String, dynamic>)
        .copyWith(id: doc.id);
  }
}

class _ServerTimestampConverter implements JsonConverter<FieldValue, Object> {
  const _ServerTimestampConverter();

  @override
  FieldValue fromJson(Object json) => FieldValue.serverTimestamp();

  @override
  Object toJson(FieldValue fieldValue) => fieldValue;
}
