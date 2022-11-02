import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hehewhoknows/services/cloud/cloud_notes.dart';
import 'package:hehewhoknows/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage{

  final notes = FirebaseFirestore.instance.collection("notes");

  void createNewNote({required String ownerUserID}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserID,
      textFieldName: "",
    });
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserID}) async {
    try{
      await notes.where(ownerUserIdFieldName,
        isEqualTo: ownerUserID
      ).get()
          .then(
          (value) => value.docs.map(
              (doc) => CloudNote(
                documentID: doc.id,
                ownerUserID: doc.data()[ownerUserIdFieldName] as String,
                text: doc.data()[textFieldName] as String,
              ),
          ),
      );
    }catch(e){
      throw CouldNotGetAllNotesException();
    }
  }


  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}






const ownerUserIdFieldName = 'user_id';
const textFieldName = 'text';