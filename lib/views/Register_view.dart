import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/services/auth/auth_exceptions.dart';
import 'package:hehewhoknows/services/auth/auth_service.dart';
import 'package:hehewhoknows/utilities/showErrorDialog.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text("Register")
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
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                AuthService.firebase().sendEmailVerification();
                //automatically send email verification to the registered email;
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } // try
              on WeakPasswordAuthException{
                await showErrorDialog(
                  context,
                  "Weak Password!",
                );
              }
              on EmailAlreadyInUseAuthException{
                await showErrorDialog(
                  context,
                  "Email is already registered!",
                );
              }
              on InvalidEmailAuthException{
                await showErrorDialog(
                  context,
                  "Invalid email entered!",
                );
              }
              on GenericAuthException{
                await showErrorDialog(
                  context,
                  "Failed to register!",
                );
              }
            },
            child: const Text("Register"),
          ),
          TextButton(onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
            (route) => false,
            );
          },
              child: const Text("Already Registered? Sign in here!"),
          )
        ],
      ),
    );
  }
}