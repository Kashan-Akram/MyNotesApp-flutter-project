import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/views/Login_view.dart';
import 'package:hehewhoknows/views/Register_view.dart';
import 'package:hehewhoknows/views/Verify_Email.dart';
import 'firebase_options.dart';

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
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
             final user = FirebaseAuth.instance.currentUser;
             if(user != null){
               if(user.emailVerified){
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

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
            actions: [
      PopupMenuButton<MenuAction>(
      onSelected: (value) async {
        switch(value){
          case MenuAction.logout:
            final shouldLogout = await showLogOutDialog(context);
           // devtools.log(shouldLogout.toString());
            if(shouldLogout){
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                   (route) => false,
              );
            }
        }
      },
      itemBuilder: (context){
                return const[
                  PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text("Sign Out")
                  ),
                ];
            },
          ),
        ], // actions
      ),
      body: const Text("Hello World!"),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text("Sign Out"),
          content: const Text("Are you sure you want to Sign Out?"),
          actions: [
        TextButton(onPressed:(){
          Navigator.of(context).pop(false);
        },
            child: const Text("Cancel")
        ),
        TextButton(onPressed:(){
          Navigator.of(context).pop(true);
        },
            child: const Text("Sign Out")
        ),
          ],
        );
      },
  ).then( (value) => value ?? false );
}


