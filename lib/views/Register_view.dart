import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';
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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                await user!.sendEmailVerification();
                //automatically send email verification to the registered email;
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } // try
              on FirebaseAuthException catch(e){
                if(e.code == "weak-password"){
                  await showErrorDialog(
                    context,
                    "Weak Password!",
                  );
                }else if(e.code == "email-already-in-use"){
                  await showErrorDialog(
                      context,
                      "Email is already registered!",
                  );
                }else if(e.code == "invalid-email"){
                  await showErrorDialog(
                      context,
                      "Invalid email entered!",
                  );
                }else{
                  await showErrorDialog(
                    context,
                    "Error ${e.code}",
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