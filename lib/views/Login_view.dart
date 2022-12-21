import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hehewhoknows/services/auth/auth_exceptions.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_bloc.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_event.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_state.dart';
import 'package:hehewhoknows/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController? _email;
  TextEditingController? _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email!.dispose();
    _password!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context,
                "Cannot find a user with the entered credentials!",
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
                context,
                "Wrong Credentials!",
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
                context,
                "Authentication Error!",
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sign in"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please sign in to your account to continue!"),
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Enter your email",
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: "Enter your password",
                ),
              ),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final email = _email!.text;
                        final password = _password!.text;
                        context.read<AuthBloc>().add(
                          AuthEventLogIn(email, password),
                        );
                      },
                      child: const Text("Sign in"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          const AuthEventForgotPassword(),
                        );
                      },
                      child: const Text("Forgot your password? Reset here!"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                        /*
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          registerRoute,
                              (route) => false,
                        );
                        */
                      },
                      child: const Text("Not registered yet? Register here!"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
// pre-bloc login button on pressed logic after grabbing email and password:-
try {
await AuthService.firebase().logIn(
email: email,
password: password,
);
final user = AuthService.firebase().currentUser;
if(user!.isEmailVerified){
//user's email is verified
Navigator.of(context).pushNamedAndRemoveUntil(
notesRoute,
(route) => false,
);
}else{
//user's email is not verified
Navigator.of(context).pushNamedAndRemoveUntil(
verifyEmailRoute,
(route) => false,
);
}
} on UserNotFoundAuthException {
await showErrorDialog(
context,
"User not found!",
);
} on WrongPasswordAuthException {
await showErrorDialog(
context,
"Wrong Credentials!",
);
} on GenericAuthException {
await showErrorDialog(
context,
"Authentication Error!",
);
}
 */


