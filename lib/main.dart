import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hehewhoknows/views/Login_view.dart';
import 'package:hehewhoknows/views/Register_view.dart';
import 'firebase_options.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.pink,
    ),
    home: const HomePage(),
      routes: {
        "/login/" : (context) => const LoginView(),
        "/register/" : (context) => const RegisterView(),
      },
  ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
          /*   final user = FirebaseAuth.instance.currentUser;
              if(user!.emailVerified){
                //print("You are a verified user");
                return const Text("Done!");
              }else{
                //print("You need to verify your email first!");
               return const VerifyEmail();
              } */
            return const LoginView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}


