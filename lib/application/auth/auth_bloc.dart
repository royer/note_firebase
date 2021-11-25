import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:note_firebase/domain/auth/i_auth_facade.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthFacade _authFacade;

  AuthBloc(this._authFacade) : super(const _Initial()) {
    // on<AuthEvent>((event, emit) async {
    //   event.map(
    //     authCheckRequested: (_) async {
    //       final userOption = await _authFacade.getSignedInUser();
    //       userOption.fold(
    //         () => emit(const AuthState.unauthenticated()),
    //         (_) => emit(const AuthState.authenticated()),
    //       );
    //     },
    //     signedOut: (_) async {
    //       await _authFacade.signOut();
    //       emit(const AuthState.unauthenticated());
    //     },
    //   );
    // });
    on<AuthCheckRequested>((event, emit) async {
      log('on event: ${event.runtimeType}');
      final userOption = await _authFacade.getSignedInUser();
      userOption.fold(
        () => emit(const AuthState.unauthenticated()),
        (_) => emit(const AuthState.authenticated()),
      );
    });

    on<SignedOut>((event, emit) async {
      log('on event: ${event.runtimeType}');

      await _authFacade.signOut();
      emit(const AuthState.unauthenticated());
    });
  }
}
