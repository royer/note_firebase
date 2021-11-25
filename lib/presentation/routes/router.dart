import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:note_firebase/presentation/notes/note_form/note_form_page.dart';
import 'package:note_firebase/presentation/notes/notes_overview/notes_overview_page.dart';
import 'package:note_firebase/presentation/sign_in/sign_in_page.dart';
import 'package:note_firebase/presentation/splash/splash_page.dart';
import 'package:note_firebase/domain/notes/note.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashPage, initial: true),
    AutoRoute(page: SignInPage),
    AutoRoute(page: NotesOverviewPage),
    AutoRoute(page: NoteFormPage, fullscreenDialog: true),
  ],
)
class AppRouter extends _$AppRouter {}
