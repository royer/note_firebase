part of 'sign_in_form_bloc.dart';

@freezed
class SignInFormEvent with _$SignInFormEvent {
  const factory SignInFormEvent.emailChanged(String emailStr) = EmailChanged;
  const factory SignInFormEvent.passwordChanged(String passwordStr) =
      PasswordChanged;
  const factory SignInFormEvent.registerWithEmailAndPasswordPressed() =
      RegisterWithEmailAndPasswordPressed;
  const factory SignInFormEvent.signWithEmailAndPasswordPressed() =
      SignWithEmailAndPasswordPressed;
  const factory SignInFormEvent.signWithGooglePressed() = SignWithGooglePressed;
}
