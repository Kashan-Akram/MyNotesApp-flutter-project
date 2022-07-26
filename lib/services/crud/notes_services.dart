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

const idColumn = "id";
const emailColumn = "email";