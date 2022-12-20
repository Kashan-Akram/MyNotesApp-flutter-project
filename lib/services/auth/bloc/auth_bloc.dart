import 'package:bloc/bloc.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_event.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_state.dart';
import 'package:hehewhoknows/services/auth/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()){

    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(null));
      }else if(!user.isEmailVerified){
        emit(const AuthStateNeedsVerification());
      }else{
        emit(AuthStateLoggedIn(user));
      }
    });

    // log in
    on<AuthEventLogIn>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try{
        final user = await provider.logIn(
            email: email,
            password: password,
        );
        emit(AuthStateLoggedIn(user));
      } on  Exception catch(e){
        emit(AuthStateLoggedOut(e));
      }
    });

    // log out
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoading());
      try{
        await provider.logOut();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch(e){
        emit(AuthStateLogOutFailure(e));
      }
    });

  }
}