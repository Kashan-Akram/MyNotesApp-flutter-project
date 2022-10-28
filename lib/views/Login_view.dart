import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/services/auth/auth_exceptions.dart';
import 'package:hehewhoknows/services/auth/auth_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in"),
      ),
      body: Column(
        children: [
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

          TextButton(
            onPressed: () async {
              final email = _email!.text;
              final password = _password!.text;
              try{
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
              } // try
              on UserNotFoundAuthException{
                await showErrorDialog(
                  context,
                  "User not found!",
                );
              }
              on WrongPasswordAuthException{
                await showErrorDialog(
                  context,
                  "Wrong Credentials!",
                );
              }
              on GenericAuthException{
                await showErrorDialog(
                  context,
                  "Authentication Error!",
                );
              }
            },
            child: const Text("Sign in"),
          ),
          TextButton(
            onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
            registerRoute,
            (route) => false,
            );
          },
            child: const Text("Not registered yet? Register here!"),
          )
        ],
      ),
    );
  }
}





















