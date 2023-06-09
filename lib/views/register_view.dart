import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

import '../services/auth/auth_exceptions.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your e-mail here',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,

            decoration: const InputDecoration(
              hintText: 'Enter your Password here',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try{
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
               AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
              }

              on WeakPasswordAuthException {
                await showErrorDialog(context, 'weak Password',);
              }

              on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, 'Email already in use',);
              }

              on InvalidEmailAuthException {
                await showErrorDialog(context, 'Invalid Email Entered',);
              }

              on GenericAuthException{
                await showErrorDialog(context, 'Failed to register',);
              }
            },
            child: const Text('Register'),
          ),
        TextButton(onPressed: (){
         Navigator.of(context).pushReplacementNamed(loginRoute);
        },
            child: const Text('Already Registered? Login here!'),
          )
        ],
      ),
    );
  }
}