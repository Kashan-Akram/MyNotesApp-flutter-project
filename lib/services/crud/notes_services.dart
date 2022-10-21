import 'package:flutter/foundation.dart';
import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart";
import "package:path/path.dart" show join;
import 'crud_exceptions.dart';

class NotesServices{
  Database? _db;

  Future<DatabaseNote> updateNote(
    {required DatabaseNote note, required String text }) async {
      final db = _getDatabaseOrThrow();
      // checking if the note we want to update already exists or not
      // if it does not exits our getNote function will throw error
      await getNote(id: note.id);
      final updateCount = await db.update(noteTable,
        {
          textColumn: text,
          isSyncedWithCloudColumn: 0,
        }
      );
      if(updateCount == 0){
        throw CouldNoteUpdateNote();
      }else{
        return await getNote(id: note.id);
      }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable,
      limit : 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if(notes.isEmpty){
      throw CouldNoteFindNote();
    }else{
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    // making sure that the user that wants to create notes actually exists in the database
    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner){
      throw CouldNotFindUser();
    }
    const text = "";
    // creating notes
    final noteId = await db.insert(noteTable,
      {
      userIDColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
      },
    );
    final note = DatabaseNote(
      id: noteId,
      userID: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<void> deleteNote({required int id}) async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if(deletedCount == 0){
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
      limit : 1,
      where : "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if(results.isEmpty){
      throw CouldNotFindUser();
    }else{
      return DatabaseUser.fromRow(results.first);
    }

  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit : 1,
        where : "email = ?",
        whereArgs: [email.toLowerCase()],
    );
    if(results.isNotEmpty){
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable,
        {
          emailColumn: email.toLowerCase(),
        },
    );

    return DatabaseUser(
        id: userId,
        email: email,
    );

  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if(deletedCount != 1){
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db == null){
      throw DatabaseNotOpen();
    }else{
      return db;
    }
  }

  Future<void> close() async{
    final db = _db;
    if(db == null){
      throw DatabaseNotOpen();
    }else{
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }

  try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // creating the user table
      await db.execute(createUserTable);

      // creating the notes table
      await db.execute(createNotesTable);

  } on MissingPlatformDirectoryException{
    throw UnableToGetDocumentsDirectory();
  }
  }

}

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

// we can consolidate all of our constants here to make code look cleaner
const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIDColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
      "id"	INTEGER NOT NULL,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      ); ''';
const createNotesTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT,
      FOREIGN KEY("user_id") REFERENCES "user"("id"),
      PRIMARY KEY("id" AUTOINCREMENT)
      );''';
