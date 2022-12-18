import 'package:flutter/material.dart';
import 'package:hehewhoknows/services/auth/auth_service.dart';
import 'package:hehewhoknows/utilities/dialogs/cannot_share_empty_note_dialog.dart';
//import 'package:hehewhoknows/services/crud/notes_services.dart';
import 'package:hehewhoknows/utilities/generics/get_arguments.dart';
import 'package:hehewhoknows/services/cloud/cloud_notes.dart';
import 'package:hehewhoknows/services/cloud/cloud_storage_exceptions.dart';
import 'package:hehewhoknows/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {

  CloudNote? _note;
  late final FirebaseCloudStorage _notesServices;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesServices = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesServices.updateNotes(documentID: note.documentID, text: text);
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {

    final widgetNote = context.getArgument<CloudNote>();
    if(widgetNote != null){
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userID = currentUser.id;
    //final owner = await _notesServices.getUser(email: email);
    final newNote = await _notesServices.createNewNote(ownerUserID: userID);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextisEmpty(){
    final note = _note;
    if(_textController.text.isEmpty && note != null){
      _notesServices.deleteNote(documentID: note.documentID);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if(note != null && text.isNotEmpty){
      await _notesServices.updateNotes(documentID: note.documentID, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextisEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        actions: [
          IconButton(
              onPressed: () async {
                final text = _textController.text;
                if(_note == null || text.isEmpty){
                  await showCannotShareEmptyNoteDialog(context);
                }else{
                  Share.share(text);
                }
              },
              icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Type your note here...",
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
