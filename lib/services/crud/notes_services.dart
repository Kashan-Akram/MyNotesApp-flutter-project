import 'package:flutter/foundation.dart';
import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart"
    show getApplicationDocumentsDirectory;
import "package:path/path.dart" show join;
@immutable
class DatabaseUser{
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map) :
        id = map[idColumn] as int,
        email = map[emailColumn] as String;

@override
  String toString()=> "Person, ID = $id, email = $email";

  @override bool operator == (covariant DatabaseUser other) =>
      id == other.id;

  @override
  int get hashCode => id.hashCode;


}

class DatabaseNote{
  final int id;
  final int userID;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userID,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map) :
        id = map[idColumn] as int,
        userID = map[userIDColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
          (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;



  @override
  String toString()=>
      "Note, ID = $id, userID = $userID, isSyncedWithCloud = $isSyncedWithCloud";

  @override bool operator == (covariant DatabaseNote other) =>
      id == other.id;

  @override
  int get hashCode => id.hashCode;
}


const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIDColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";






