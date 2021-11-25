import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_firebase/application/auth/auth_bloc.dart';
import 'package:note_firebase/application/notes/note_actor/note_actor_bloc.dart';
import 'package:note_firebase/application/notes/note_watcher/note_watcher_bloc.dart';
import 'package:note_firebase/domain/notes/note.dart';
import 'package:note_firebase/presentation/notes/notes_overview/widgets/notes_overview_body_widget.dart';
import 'package:note_firebase/presentation/notes/notes_overview/widgets/uncompleted_switch.dart';
import 'package:note_firebase/presentation/routes/router.dart';

import '../../../injection.dart';

class NotesOverviewPage extends StatelessWidget implements AutoRouteWrapper {
  const NotesOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log('$context', name: 'MyLog');
    log('context.read<AuthBloc>: ${context.read<AuthBloc>().runtimeType}',
        name: 'MyLog');
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteWatcherBloc>(
          create: (_) => getIt<NoteWatcherBloc>()
            ..add(const NoteWatcherEvent.watchAllStarted()),
        ),
        BlocProvider<NoteActorBloc>(create: (_) => getIt<NoteActorBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(listener: (context, state) {
            log('listened AuthBloc state($state) in $runtimeType');
            state.maybeMap(
              unauthenticated: (_) {
                log('AuthBloc listener in NotesOverviewPage listened unauthenticated event.');
                AutoRouter.of(context).replace(const SignInRoute());
              },
              orElse: () {
                log('orElse of listen AuthBloc state in NotesOverviewPage',
                    name: 'MyLog');
              },
            );
          }),
          BlocListener<NoteActorBloc, NoteActorState>(
              listener: (context, state) {
            state.maybeMap(
              deleteFailure: (s) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.noteFailure.map(
                        unexpected: (_) => 'unexpected',
                        insufficientPermission: (_) => 'insufficientPermission',
                        unableToUpdate: (_) => 'unableToUpdate',
                      ),
                    ),
                  ),
                );
              },
              deleteSuccess: (s) {},
              orElse: () {},
            );
          }),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Notes'),
            leading: IconButton(
              onPressed: () {
                log('$runtimeType exit button pressed.', name: 'MyLog');
                context.read<AuthBloc>().add(const AuthEvent.signedOut());
              },
              icon: const Icon(Icons.exit_to_app),
            ),
            actions: [
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.indeterminate_check_box),
              // ),
              UncompletedSwitch(),
            ],
          ),
          body: const NotesOverviewBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.router.push(NoteFormRoute(editedNote: null));
            },
            child: const Icon(Icons.add),
          ),
        ),
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
