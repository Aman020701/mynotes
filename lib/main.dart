import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_e-mail_view.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      loginRoute:(context) => const LoginView(),
      registerRoute:(context) => const RegisterView(),
      notesRoute:(context) => const NotesView(),
      verifyEmailRoute:(context) => const VerifyEmailView(),
    },
  )
  );
}
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context,snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.done:
          final user  = AuthService.firebase().currentUser;
          final emailVerified = user?.isEmailVerified ?? false;
          if(user != null){
            if(emailVerified)
              return const NotesView();
            else{
              return const VerifyEmailView();
            }
          }
          else{
            return LoginView();
          }
          return const Text('Done');
          default:
            return CircularProgressIndicator();
        }

      },
    );
  }
}




