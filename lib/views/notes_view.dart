import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/enums/menu_action.dart';
import 'package:hehewhoknows/services/auth/auth_service.dart';

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
                    await AuthService.firebase().logOut();
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