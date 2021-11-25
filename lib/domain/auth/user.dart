import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_firebase/domain/core/value_objects.dart';

part 'user.freezed.dart';

@freezed
class MyUser with _$MyUser {
  const factory MyUser({required UniqueId uid}) = _MyUser;
}
