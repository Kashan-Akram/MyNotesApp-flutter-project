import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hehewhoknows/services/cloud/cloud_notes.dart';
import 'package:hehewhoknows/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage{

  final notes = FirebaseFirestore.instance.collection("notes");

  Future<CloudNote> createNewNote({required String ownerUserID}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserID,
      textFieldName: "",
    });
    final fetchedNote = await document.get();
    return CloudNote(
        documentID: fetchedNote.id,
        ownerUserID: ownerUserID,
        text: "",
    );
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserID}) async {
    try{
      return await notes.where(ownerUserIdFieldName,
        isEqualTo: ownerUserID
      ).get()
          .then(
          (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
                /*
                CloudNote(
                  documentID: doc.id,
                  ownerUserID: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                ),
                */
          ),
      );
    }catch(e){
      throw CouldNotGetAllNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserID}) {
    return notes.snapshots().map((event) => event.docs
      .map((doc) => CloudNote.fromSnapshot(doc))
      .where((note) => note.ownerUserID == ownerUserID));
  }

  Future<void> updateNotes({
    required String documentID,
    required String text,
    }) async {
      try{
        await notes.doc(documentID).update({textFieldName: text});
      }catch(e){
        throw CouldNotUpdateNoteException();
      }
  }

  Future<void> deleteNote({required String documentID}) async {
    try{
      await notes.doc(documentID).delete();
    } catch(e){
      CouldNotDeleteNoteException();
    }
  }

  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}

const ownerUserIdFieldName = 'user_id';
const textFieldName = 'text';

