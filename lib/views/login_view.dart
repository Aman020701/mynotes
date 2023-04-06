import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
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
                final usercredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                Navigator.of(context).pushReplacementNamed('/notes');
                devtools.log(usercredential.toString());
              } on FirebaseAuthException catch (e){
                if(e.code == 'user not found')
                  devtools.log('user not found');
                else if(e.code == 'wrong password')
                  devtools.log('wrong password');
              }
            },
            child: const Text('Login'),
          ),
          TextButton(onPressed: (){
            Navigator.of(context).pushReplacementNamed('/register');
            // its given something else in video but this worked

            },
              child: const Text('Not Registered yet? Register here'),
          )
        ],
      ),
    );
  }
}


