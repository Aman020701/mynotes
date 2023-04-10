import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import '../constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify e-mail'),
      ),
      body: Column(
        children: [
          const Text('we have sent you an e-mail verification please check your e-mail'),
          const Text("if you haven't recieved mail please click button below"),
          TextButton(onPressed: () async{
            final User = AuthService.firebase().currentUser;
            AuthService.firebase().sendEmailVerification();
          }, child: const Text('send e-mail Verification')),
          TextButton(onPressed:  () async {
            await AuthService.firebase().logOut();
            Navigator.of(context).pushReplacementNamed(registerRoute);
          }, child: const Text("Restart"))
        ],
      ),
    );
  }
}