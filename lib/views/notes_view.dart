import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import '../constants/routes.dart';
import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState(){
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose(){
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          PopupMenuButton <MenuAction>(
            onSelected:(value) async{
              switch(value){
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if(shouldLogout){
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushReplacementNamed(loginRoute);
                  }
              }
            },
            itemBuilder: (context){
              return const[
                PopupMenuItem <MenuAction>(
                  value : MenuAction.logout,
                  child: const Text('Log Out'),
                )
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot){

          switch(snapshot.connectionState){
            case ConnectionState.done:
            // TODO: Handle this case.
               return StreamBuilder(
                   stream: _notesService.allNotes,
                   builder: (context,snapshot){
                     switch(snapshot.connectionState){
                       case ConnectionState.waiting:
                         // TODO: Handle this case.
                        return const Text('Waiting for all Notes');
                         break;
                       default :
                         return const CircularProgressIndicator();
                     }
                   }
               );
              break;
            default :
              return const CircularProgressIndicator();
          }
          }
      )
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){

  return showDialog <bool>(
    context: context,
    builder: (context){
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop(false);

          }, child: const Text('Cancel'),
          ),
          TextButton(onPressed: (){
            Navigator.of(context).pop(true);


          }, child: const Text('Log Out'),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}
