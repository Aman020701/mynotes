import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:mynotes/services/crud/crud_exceptions.dart';

   class NotesService{

   List <DatabaseNote> _notes = [];

   static final NotesService _shared = NotesService._sharedInstance();
   NotesService._sharedInstance();
   factory NotesService() => _shared;

   final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

   Stream <List<DatabaseNote>> get allNotes => _notesStreamController.stream;

   Future<DatabaseUser> getOrCreateUser ({required String email}) async{

     try{
       final user = await getUser(email: email);
       return user;
     }
     on couldNotFindUser{
       final createdUser = await createUser(email: email);
       return createdUser;
     } catch (e){
       rethrow;
     }
   }

   Future<void> _cacheNotes() async{
     final allNotes = await getAllNote();
     _notes = allNotes.toList();
     _notesStreamController.add(_notes);

   }
   Database?_db;

   Future <DatabaseNote> updateNote({required DatabaseNote note,required String text}) async {
     await _ensureDbIsOpen();
     final db = _getDatabaseOrThrow();

     // make sure note exist
     await getNote(id: note.id);

     // update db
     final  updateCount = await db.update(notesTable, {

       textColumn : text,
       isSyncedWithCloudColumn : 0
     });

     if(updateCount == 0){
       throw couldNotUpdateNote();
     }
     else {
       final updatedNote = await getNote(id: note.id);
       _notes.removeWhere((note) => note.id == updatedNote.id);
       _notes.add(updatedNote);
       _notesStreamController.add(_notes);
       return updatedNote;
     }
   }

   Future <Iterable<DatabaseNote>> getAllNote () async{
     await _ensureDbIsOpen();
     final db = _getDatabaseOrThrow();
     final notes = await db.query(notesTable);
     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
   }

   Future <DatabaseNote> getNote ({required int id}) async{

     await _ensureDbIsOpen();
     final db = _getDatabaseOrThrow();
     final notes = await db.query(notesTable,limit: 1,where: 'id = ?',whereArgs: [id]);

     if(notes.isEmpty){
       throw couldNotFindNote();
     }
     else{
       final note = DatabaseNote.fromRow(notes.first);
       // removing old note from cache whose id is equal to note
       _notes.removeWhere((note) => note.id == id);
       // updating note
       _notes.add(note);
       _notesStreamController.add(_notes);
       return note;
     }
   }

   Future <int> deleteAllNotes () async{
     await _ensureDbIsOpen();
     final db = _getDatabaseOrThrow();
     final numberOfDeletions = await db.delete(notesTable);
     _notes = [];
     _notesStreamController.add(_notes);
     return numberOfDeletions;
   }

   Future <void> deleteNote({required int id}) async {
     await _ensureDbIsOpen();
     final db = _getDatabaseOrThrow();
     final deletedCount = await db.delete(notesTable,where: 'id = ?',whereArgs: [id],);

     if(deletedCount == 0){
       throw CouldNotDeleteNote();
     }
     else{
       _notes.removeWhere((note) => note.id == id);
       _notesStreamController.add(_notes);
     }
   }

   Future <DatabaseNote> createNote({required DatabaseUser owner}) async{

     await _ensureDbIsOpen();
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

     _notes.add(note);
     _notesStreamController.add(_notes);

     return note;

   }

   Future <DatabaseUser> getUser({required String email}) async{
     await _ensureDbIsOpen();
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
     await _ensureDbIsOpen();
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
     await _ensureDbIsOpen();
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

   Future <void> _ensureDbIsOpen() async {
    try{
      await open();
    } on DatabaseAlreadyOpenException{
    //  empty
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
     // create user table
     await db.execute(createUserTable);
     // create note table
     await db.execute(createNoteTable);
     await _cacheNotes();
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