import 'dart:async';
import 'package:flutter/foundation.dart';
import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart";
import "package:path/path.dart" show join;
import 'crud_exceptions.dart';

class NotesServices{
  Database? _db;
  List<DatabaseNote> _notes = [];

  // making our class NoteServices a SingleTon
  static final NotesServices _shared = NotesServices._sharedInstance();
  NotesServices._sharedInstance();
  factory NotesServices() => _shared;

  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try{
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser{
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch(e){
      rethrow;
    }
  }

  //using the "_" as prefix in a function name tells dart that
  //we are having this function as private to our file
  //functions without "_" prefix can be used publicly out someplace
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote(
    {required DatabaseNote note, required String text }) async {
      await _ensureDBisOpen();
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
        final updatedNote = await getNote(id: note.id);
        _notes.removeWhere((note) => note.id == updatedNote.id);
        _notes.add(updatedNote);
        _notesStreamController.add(_notes);
        return updatedNote;
      }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable,
      limit : 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if(notes.isEmpty){
      throw CouldNoteFindNote();
    }else{
      final note = DatabaseNote.fromRow(notes.first);

      //in this function there is a possibility that the note we are trying to get
      //has been updated but since the id remains the same it could be an issue that
      //a copy of that note already exists in the cache and its not updated with
      //the latest changes we had applied to the note
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDBisOpen();
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

    // caching the newly created note
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> deleteNote({required int id}) async{
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if(deletedCount == 0){
      throw CouldNotDeleteNote();
    }else{
      //we need to also remove it from the cached notes list
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);

    // also need to remove all notes from cache
    _notes = [];
    _notesStreamController.add(_notes);

    return numberOfDeletions;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBisOpen();
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
    await _ensureDBisOpen();
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
    await _ensureDBisOpen();
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

  Future<void> _ensureDBisOpen() async {
    try{
      await open();
    } on DatabaseAlreadyOpenException {
      // empty, just let it go
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
      //after we've made sure that all the tables are open and database
      //is reactive we are going to create a stream and stream controller
      //with the help of _cacheNotes function
      await _cacheNotes();
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
