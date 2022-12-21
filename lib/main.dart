import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/helpers/loading/loading_screen.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_bloc.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_event.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_state.dart';
import 'package:hehewhoknows/services/auth/firebase_auth_provider.dart';
import 'package:hehewhoknows/views/Login_view.dart';
import 'package:hehewhoknows/views/Register_view.dart';
import 'package:hehewhoknows/views/Verify_Email_view.dart';
import 'package:hehewhoknows/views/forgot_password_view.dart';
import 'package:hehewhoknows/views/notes/notes_view.dart';
import 'package:hehewhoknows/views/notes/create_update_note_view.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.pink,
    ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        /*
        loginRoute : (context) => const LoginView(),
        registerRoute : (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmail(),
        */
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
  ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state){
        if(state.isLoading){
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? "Please wait a moment",
          );
        }else{
          LoadingScreen().hide();
        }
      },
      builder: (context, state){
        if(state is AuthStateLoggedIn){
          return const NotesView();
        }else if(state is AuthStateNeedsVerification){
          return const VerifyEmail();
        }else if(state is AuthStateLoggedOut){
          return const LoginView();
        }else if(state is AuthStateForgotPassword){
          return const ForgotPasswordView();
        }else if(state is AuthStateRegistering){
          return const RegisterView();
        }else{
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
    });
  }
}






/*
// an increment decrement counter application created using bloc to
// get familiar with bloc and flutter_bloc
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Testing Bloc"),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state){
            _controller.clear();
          },
          builder: (context, state){
            final invalidValue =
              state is CounterStateInvalid ? state.invalidValue : "";
            return Column(
              children: [
                Text("Current Value => ${state.value}"),
                Visibility(
                  child: Text("Invalid Input: $invalidValue"),
                  visible: state is CounterStateInvalid,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Enter a number here",
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          context
                            .read<CounterBloc>()
                              .add(DecrementEvent(_controller.text));
                        },
                        child: const Text("-"),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                          .read<CounterBloc>()
                            .add(IncrementEvent(_controller.text));
                      },
                      child: const Text("+"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState{
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState{
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalid extends CounterState{
  final String invalidValue;
  const CounterStateInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue) ;
}

@immutable
abstract class CounterEvent{
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent{
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent{
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)){
    on<IncrementEvent>((event, emit){
      final integer = int.tryParse(event.value);
      if(integer == null){
        emit(
          CounterStateInvalid(
              invalidValue: event.value,
              previousValue: state.value,
          ),
        );
      }else{
        emit( CounterStateValid(state.value + integer) );
      }
    });
    on<DecrementEvent>((event, emit){
      final integer = int.tryParse(event.value);
      if(integer == null){
        emit(
          CounterStateInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      }else{
        emit( CounterStateValid(state.value - integer) );
      }
    });
  }
}
*/