import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable // internals are never gonna change upon initialization
class AuthUser{
  final bool isEmailVerified;
  const AuthUser({required this.isEmailVerified});
  factory AuthUser.fromFirebase(User user) => AuthUser(isEmailVerified : user.emailVerified); // taking reference from user in firebase class

}
