import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:mynotes/services/crud/crud_exceptions.dart';

 class NotesService{

   Database?_db;

   Future <DatabaseNote> updateNote({required DatabaseNote note,required String text}) async {

     final db = _getDatabaseOrThrow();

     await getNote(id: note.id);
     
     final  updateCount = await db.update(notesTable, {

       textColumn : text,
       isSyncedWithCloudColumn : 0
     });

     if(updateCount == 0){
       throw couldNotUpdateNote();
     }
     else {
       return await getNote(id: note.id);
     }
   }

   Future <Iterable<DatabaseNote>> getAllNote () async{
     final db = _getDatabaseOrThrow();
     final notes = await db.query(notesTable);
     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
   }

   Future <DatabaseNote> getNote ({required int id}) async{

     final db = _getDatabaseOrThrow();
     final notes = await db.query(notesTable,limit: 1,where: 'id = ?',whereArgs: [id]);

     if(notes.isEmpty){
       throw couldNotFindNote();
     }
     else{
       return DatabaseNote.fromRow(notes.first);
     }
   }

   Future <int> deleteAllNotes () async{

     final db = _getDatabaseOrThrow();
     return await db.delete(notesTable);
   }

   Future <void> deleteNote({required int id}) async {
     final db = _getDatabaseOrThrow();
     final deletedCount = await db.delete(notesTable,where: 'id = ?',whereArgs: [id],);

     if(deletedCount == 0){
       throw CouldNotDeleteNote();
     }
   }

   Future <DatabaseNote> createNote({required DatabaseUser owner}) async{

     // make sure user exists in the database with the current ID
     final db = _getDatabaseOrThrow();

     final dbUser  = await getUser(email: owner.email);
     if(dbUser != owner){
         throw couldNotFindUser();
     }
     const text = '';
     final noteId = await db.insert(notesTable, {
       userIdColumn : owner.id,
       textColumn : text,
       isSyncedWithCloudColumn : 1
     });

     final note = DatabaseNote(id: noteId, userId: owner.id, text: text, isSynced: true);
     return note;

   }

   Future <DatabaseUser> getUser({required String email}) async{
     final db = _getDatabaseOrThrow();
     final result = await db.query(userTable,limit: 1,where: 'email = ?',whereArgs: [email.toLowerCase()]);

     if(!result.isEmpty){
       throw couldNotFindUser();
     }
     else {
       return DatabaseUser.fromRow(result.first);
     }
   }

   Future <DatabaseUser> createUser({required String email}) async{

     final db = _getDatabaseOrThrow();
     final result = await db.query(userTable,limit: 1,where: 'email = ?',whereArgs: [email.toLowerCase()]);

     if(!result.isEmpty){
       throw userAlreadyExists();
     }
    final userId = await db.insert(userTable, {
       emailColumn : email.toLowerCase(),
     });
     
     return DatabaseUser(id: userId, email: emailColumn);
   }

   Future <void> deleteUser({required String email}) async {
     final db = _getDatabaseOrThrow();
     final deletedCount = db.delete(userTable,where: 'email = ?',whereArgs: [email.toLowerCase()]);

     if(deletedCount != 1){
       throw CouldNotDeleteUser();
     }
   }

   Database _getDatabaseOrThrow(){

     final db = _db;

     if(db == null){
       throw DatabaseNotOpen();
     }
     else {
       return db;
     }
   }

   Future <void> close() async{
      final db = _db;

      if(db == null){
        throw DatabaseNotOpen();
      }
      else{
        await db.close();
        _db = null;
      }
   }

   Future <void> open() async{
   if(_db != null){
     throw DatabaseAlreadyOpenException();
   }

   try{
     final docsPath = await getApplicationDocumentsDirectory();
     final dbPath = join(docsPath.path,dbName);
     final db = await openDatabase(dbPath);
     _db = db;
     await db.execute(createUserTable);
     await db.execute(createNoteTable);

   } on MissingPlatformDirectoryException{
     throw UnableToGetDocumentsDirectory();
   }
   }
 }

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map <String,Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;

}
const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	     "ID"	INTEGER NOT NULL,
	     "email"	INTEGER NOT NULL UNIQUE,
	     PRIMARY KEY("ID" AUTOINCREMENT)
     ); );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	    "ID"	INTEGER NOT NULL,
	    "user_id"	INTEGER NOT NULL,
	    "text"	NUMERIC,
	    "is_synced"	INTEGER NOT NULL DEFAULT 0,
	     FOREIGN KEY("user_id") REFERENCES "user"("ID"),
	     PRIMARY KEY("ID" AUTOINCREMENT)
       );''';


class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSynced;

  DatabaseNote({required this.id, required this.userId, required this.text, required this.isSynced});

  DatabaseNote.fromRow(Map <String,Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSynced = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

   @override
   String toString() => 'Note, ID = $id, userId = $userId,isSyncedWithCloud = $isSynced,text = $text';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;


}