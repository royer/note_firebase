import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:note_firebase/domain/auth/auth_failure.dart';
import 'package:note_firebase/domain/auth/i_auth_facade.dart';
import 'package:note_firebase/domain/auth/value_objects.dart';

part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';
part 'sign_in_form_bloc.freezed.dart';

@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;
  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    on<SignInFormEvent>((event, emit) {
      log('on<SignInFormEvent> arrived: event: $event, state: $state',
          name: toString());
    });
    on<EmailChanged>(onEmailChanged);
    on<PasswordChanged>(onPasswordChanged);
    on<RegisterWithEmailAndPasswordPressed>(onRegisterPressed);
    on<SignWithEmailAndPasswordPressed>(onSignInWithEmailAndPassword);
    on<SignWithGooglePressed>(onSignInWithGoogle);
  }

  void onEmailChanged(EmailChanged event, Emitter<SignInFormState> emit) async {
    log('onEmailChanged handle: state: $state', name: toString());
    emit(state.copyWith(
      emailAddress: EmailAddress(event.emailStr),
      authFailureOrSuccessOption: none(),
    ));
  }

  void onPasswordChanged(
      PasswordChanged event, Emitter<SignInFormState> emit) async {
    log('handle Password CHanged', name: toString());
    emit(state.copyWith(
      password: Password(event.passwordStr),
      authFailureOrSuccessOption: none(),
    ));
  }

  void onRegisterPressed(RegisterWithEmailAndPasswordPressed event,
      Emitter<SignInFormState> emit) async {
    log('handle Register button Press', name: toString());

    Either<AuthFailure, Unit>? failureOrSuccess;
    final isEmailValid = state.emailAddress.isValid();
    final isPasswordValid = state.password.isValid();
    if (isEmailValid && isPasswordValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));

      failureOrSuccess = await _authFacade.registerWithEmailAndPassword(
          email: state.emailAddress, password: state.password);
      emit(state.copyWith(
        isSubmitting: false,
        authFailureOrSuccessOption: some(failureOrSuccess),
      ));
    }
    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: true,
      authFailureOrSuccessOption: optionOf(failureOrSuccess),
    ));
  }

  void onSignInWithEmailAndPassword(SignWithEmailAndPasswordPressed event,
      Emitter<SignInFormState> emit) async {
    log('handle Sign button press', name: toString());

    Either<AuthFailure, Unit>? failureOrSuccess;
    final isEmailValid = state.emailAddress.isValid();
    final isPasswordValid = state.password.isValid();
    if (isEmailValid && isPasswordValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));

      failureOrSuccess = await _authFacade.signWithEmailAndPassword(
          email: state.emailAddress, password: state.password);
      emit(state.copyWith(
        isSubmitting: false,
        authFailureOrSuccessOption: some(failureOrSuccess),
      ));
    }
    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: true,
      authFailureOrSuccessOption: optionOf(failureOrSuccess),
    ));
  }

  void onSignInWithGoogle(
      SignWithGooglePressed event, Emitter<SignInFormState> emit) async {
    log('handle $event .', name: toString());
    emit(state.copyWith(
      isSubmitting: true,
      authFailureOrSuccessOption: none(),
    ));
    try {
      final failureOrSuccess = await _authFacade.signWithGoogle();
      emit(state.copyWith(
        isSubmitting: false,
        authFailureOrSuccessOption: some(failureOrSuccess),
      ));
    } on PlatformException catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        authFailureOrSuccessOption: some(left(const CancelledByUser())),
      ));
    }
  }
}
