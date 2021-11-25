import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:note_firebase/domain/core/errors.dart';
import 'package:note_firebase/domain/core/failures.dart';
import 'package:uuid/uuid.dart';

@immutable
abstract class ValueObject<T> {
  const ValueObject();
  Either<ValueFailure<T>, T> get value;

  ///Throws [UnexpectedValueError] containing the [ValueFailure]
  T getOrCrash() {
    // id = identify - same as writing (right) => right;
    return value.fold((l) => throw UnexpectedValueError(l), id);
  }

  bool isValid() => value.isRight();

  // TODO NEED TO UNDERSTAND. 1. left(l) can automatic case to dynamic?
  //
  Either<ValueFailure<dynamic>, Unit> get failureOrUnit {
    return value.fold(
      (l) => left(l),
      (r) => right(unit),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ValueObject<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Value($value)';
}

class UniqueId extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;
  const UniqueId._(this.value);

  factory UniqueId() {
    return UniqueId._(right(const Uuid().v1()));
  }
  factory UniqueId.fromUniqueString(String uid) {
    return UniqueId._(right(uid));
  }
}
