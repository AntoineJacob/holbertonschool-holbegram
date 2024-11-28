import 'package:flutter/material.dart';
import 'package:holbegram/models/user.dart';
import 'package:holbegram/methods/auth_methods.dart';


// Classe pour gérer les données de l'utilisateur
class UserProvider with ChangeNotifier {
  Users? _user;
  final AuthMethods _authMethods = AuthMethods();

  // Constructeur pour initialiser les données de l'utilisateur
  Users get getUser => _user!;

  // Méthode pour rafrachir les données de l'utilisateur
  Future<void> refreshUser() async {
    Users user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}