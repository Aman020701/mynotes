import 'package:flutter/foundation.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';


class AuthService implements AuthProvider {

  final AuthProvider provider;
  const AuthService(this.provider);
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser?> createUser({required String email, required String password}) async{
    // TODO: implement createUser
    provider.createUser(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser?> logIn({required String email, required String password}) async{
    // TODO: implement logIn
    provider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() async {
    // TODO: implement logOut
    provider.logOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    // TODO: implement sendEmailVerification
    provider.sendEmailVerification();
  }

  @override
  Future<void> initialize() async {
    // TODO: implement initialize
     provider.initialize();
  }
  
}