import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() {
  runApp(
    MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.pink,
    ),
    home: const HomePage(),
  ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //late final TextEditingController _email;
  //late final TextEditingController _password;
  TextEditingController? _email;
  TextEditingController? _password;
 @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

@override/*
void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  } */
  void dispose() {
    _email!.dispose();
    _password!.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Register"),
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

          TextButton(onPressed: () async {
            final email = _email!.text;
            final password = _password!.text;
            final usercredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
            );
          },
            child: const Text("Register"),
          ),
        ],
      ),
    );
  }
}

