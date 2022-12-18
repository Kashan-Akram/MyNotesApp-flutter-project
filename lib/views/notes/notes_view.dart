import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';
import 'package:hehewhoknows/enums/menu_action.dart';
import 'package:hehewhoknows/services/auth/auth_service.dart';
import 'package:hehewhoknows/services/cloud/cloud_notes.dart';
//import 'package:hehewhoknows/services/crud/notes_services.dart';
import 'package:hehewhoknows/utilities/dialogs/logout_dialog.dart';
import 'package:hehewhoknows/views/notes/notes_list_view.dart';
import 'package:hehewhoknows/services/cloud/firebase_cloud_storage.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userID => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  //  @override
  // void dispose() {
  //   _notesService.close();
  //  super.dispose();
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text("Your Notes"),
        actions: [
          IconButton(
              onPressed:(){
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch(value){
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  //devtools.log(shouldLogout.toString());
                  if(shouldLogout){
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute,
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
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserID: userID),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
            case ConnectionState.active:
              if(snapshot.hasData){
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentID: note.documentID);
                  },
                  onTap: (note){
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              }else{
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

/*
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
 */