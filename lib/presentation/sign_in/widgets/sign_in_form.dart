import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_firebase/application/auth/auth_bloc.dart';
import 'package:note_firebase/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:note_firebase/presentation/routes/router.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        state.authFailureOrSuccessOption.fold(
            () => null,
            (either) => either.fold((failure) {
                  final String message = failure.map(
                    cancelledByUser: (_) => 'Cancelled by user.',
                    serverError: (_) => 'Server Error',
                    emailAlreadyInUse: (_) => 'email already in used.',
                    invalidEmailAndPasswordCombination: (_) =>
                        'Invalid email and password combination',
                  );
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }, (_) {
                  // Navigate to other screen.
                  AutoRouter.of(context).replace(const NotesOverviewRoute());
                  //? send event to check authenstatus. I don't think it is a good pattern.
                  //? firebase_auth has a stream ti notify authen status changed.
                  context
                      .read<Bloc>()
                      .add(const AuthEvent.authCheckRequested());
                }));
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: ListView(
              children: [
                const Text(
                  '📝',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 130),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Email',
                  ),
                  autocorrect: false,
                  onChanged: (value) => context
                      .read<SignInFormBloc>()
                      .add(SignInFormEvent.emailChanged(value)),
                  validator: (_) => context
                      .read<SignInFormBloc>()
                      .state
                      .emailAddress
                      .value
                      .fold(
                          (l) => l.maybeMap(
                              invalidEmail: (_) => 'Invalid Email',
                              orElse: () => null),
                          (r) => null),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: 'Password',
                  ),
                  autocorrect: false,
                  obscureText: true,
                  onChanged: (value) => context
                      .read<SignInFormBloc>()
                      .add(SignInFormEvent.passwordChanged(value)),
                  validator: (_) => context
                      .read<SignInFormBloc>()
                      .state
                      .password
                      .value
                      .fold(
                          (l) => l.maybeMap(
                              shortPassword: (_) => 'Invalid Password',
                              orElse: () => null),
                          (r) => null),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<SignInFormBloc>().add(
                              const SignInFormEvent
                                  .signWithEmailAndPasswordPressed());
                        },
                        child: const Text('SIGN IN'),
                      ),
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<SignInFormBloc>().add(
                              const SignInFormEvent
                                  .registerWithEmailAndPasswordPressed());
                        },
                        child: const Text('REGISTER'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<SignInFormBloc>()
                        .add(const SignInFormEvent.signWithGooglePressed());
                  },
                  child: const Text('Signin with Google'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
