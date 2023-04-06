import 'package:flutter/material.dart';

Future <void> showErrorDialog(BuildContext context, String text){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: const Text('An error occcured'),
      content: Text(text),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();   // pop out the notification
        }, child: const Text('OK'))
      ],
    );
  });
}
