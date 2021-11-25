import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_firebase/application/auth/auth_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:note_firebase/presentation/routes/router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          authenticated: (_) {
            log('authenticaed state arrived. goto mainpage');
            AutoRouter.of(context).replace(const NotesOverviewRoute());
          },
          unauthenticated: (_) {
            log('unauthenticated state arrived. goto SignInPage');
            //! auto_router will throw excpetion when use replaceNamed method
            //! context.router.replaceNamed(SignInRoute.name);
            context.router.replace(const SignInRoute());
            //AutoRouter.of(context).replaceNamed(SignInRoute.name);
          },
        );
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
