import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_firebase/application/auth/auth_bloc.dart';
import 'package:note_firebase/presentation/routes/router.dart';

import '../../injection.dart';

class AppWidget extends StatelessWidget {
  AppWidget({Key? key}) : super(key: key);

  final _appRouter = AppRouter();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                getIt<AuthBloc>()..add(const AuthEvent.authCheckRequested())),
      ],
      child: MaterialApp.router(
        routeInformationParser: _appRouter.defaultRouteParser(),
        routerDelegate: _appRouter.delegate(),
        title: 'Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          // primarySwatch: Colors.blue,
          primaryColor: Colors.green[800],
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue[900],
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        //home: const SignInPage(),
      ),
    );
  }
}
