// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

part of 'router.dart';

class _$AppRouter extends RootStackRouter {
  _$AppRouter([GlobalKey<NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    SplashRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const SplashPage());
    },
    SignInRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const SignInPage());
    },
    NotesOverviewRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const NotesOverviewPage());
    },
    NoteFormRoute.name: (routeData) {
      final args = routeData.argsAs<NoteFormRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData,
          child: NoteFormPage(editedNote: args.editedNote, key: args.key),
          fullscreenDialog: true);
    }
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(SplashRoute.name, path: '/'),
        RouteConfig(SignInRoute.name, path: '/sign-in-page'),
        RouteConfig(NotesOverviewRoute.name, path: '/notes-overview-page'),
        RouteConfig(NoteFormRoute.name, path: '/note-form-page')
      ];
}

/// generated route for [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute() : super(name, path: '/');

  static const String name = 'SplashRoute';
}

/// generated route for [SignInPage]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute() : super(name, path: '/sign-in-page');

  static const String name = 'SignInRoute';
}

/// generated route for [NotesOverviewPage]
class NotesOverviewRoute extends PageRouteInfo<void> {
  const NotesOverviewRoute() : super(name, path: '/notes-overview-page');

  static const String name = 'NotesOverviewRoute';
}

/// generated route for [NoteFormPage]
class NoteFormRoute extends PageRouteInfo<NoteFormRouteArgs> {
  NoteFormRoute({required Note? editedNote, Key? key})
      : super(name,
            path: '/note-form-page',
            args: NoteFormRouteArgs(editedNote: editedNote, key: key));

  static const String name = 'NoteFormRoute';
}

class NoteFormRouteArgs {
  const NoteFormRouteArgs({required this.editedNote, this.key});

  final Note? editedNote;

  final Key? key;

  @override
  String toString() {
    return 'NoteFormRouteArgs{editedNote: $editedNote, key: $key}';
  }
}
