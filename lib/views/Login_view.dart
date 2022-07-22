import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/utilities/showErrorDialog.dart';



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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );



                Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (route) => false,
                );
              } // try
              on FirebaseAuthException catch(e){
                if(e.code == "user-not-found"){
                  await showErrorDialog(
                    context,
                    "User not found!",
                  );
                }else if(e.code == "wrong-password"){
                  await showErrorDialog(
                    context,
                    "Wrong Credentials!",
                  );
                }else{
                  await showErrorDialog(
                    context,
                    "Error: ${e.code}",
                  );
                }
              } // catch
              catch(e){
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              } // catch
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





















