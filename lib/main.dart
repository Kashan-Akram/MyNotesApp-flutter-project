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
  ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: FutureBuilder(
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
            return const Text("loading...");
          }
        },
      ),
    );
  }
}
class VerifyEmail extends StatefulWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        const Text("Please Verify your Email!"),
        TextButton(onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          await user!.sendEmailVerification();
        },
          child: const Text("Send Email Verification"),
        )
      ],
    );
  }
}

