//flutter's
import 'package:flutter/material.dart';
//mine
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/services/auth/auth_service.dart';
import 'package:hehewhoknows/views/Login_view.dart';
import 'package:hehewhoknows/views/Register_view.dart';
import 'package:hehewhoknows/views/Verify_Email.dart';
import 'package:hehewhoknows/views/notes_view.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
    home: const HomePage(),
      routes: {
        loginRoute : (context) => const LoginView(),
        registerRoute : (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmail(),
      },
  ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
             final user = AuthService.firebase().currentUser;
             if(user != null){
               if(user.isEmailVerified){
                 return const NotesView();
               }else{
                 return const VerifyEmail();
               }
             }else{
               return const LoginView();
             }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}




