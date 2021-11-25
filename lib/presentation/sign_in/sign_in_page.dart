import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_firebase/application/auth/auth_bloc.dart';
import 'package:note_firebase/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:note_firebase/injection.dart';
import 'package:note_firebase/presentation/sign_in/widgets/sign_in_form.dart';

class SignInPage extends StatelessWidget implements AutoRouteWrapper {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: BlocProvider(
        create: (context) => getIt<SignInFormBloc>(),
        child: const SignInForm(),
      ),
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: this,
    );
  }
}
