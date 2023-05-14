import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable // internals are never gonna change upon initialization
class AuthUser{
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.email, required this.isEmailVerified});
  factory AuthUser.fromFirebase(User user) => AuthUser(email: user.email, isEmailVerified : user.emailVerified); // taking reference from user in firebase class

}
