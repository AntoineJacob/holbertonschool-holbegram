import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:holbegram/models/user.dart';
import 'package:holbegram/screens/auth/methods/user_storage.dart';

// Classe de gestion des méthodes d'authentification
class AuthMethods {
  // Initialisation des instances FirebaseAuth et FirebaseFirestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode de connexion utilisateur
  Future<String> login({
    required String email,
    required String password,
  }) async {
    // Vérification que les champs ne sont pas vides
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill all the fields';
    }

    try {
      // Connexion avec email et mot de passe
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } catch (e) {
      // En cas d'erreur, retourne le message d'erreur
      return e.toString();
    }
  }

  // Méthode d'inscription utilisateur
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    Uint8List? file,
  }) async {
    // Vérification que les champs ne sont pas vides et que le fichier est fourni
    if (email.isEmpty || password.isEmpty || username.isEmpty || file == null) {
      return 'Please fill all the fields';
    }

    try {
      // Création d'un nouvel utilisateur avec email et mot de passe
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = userCredential.user;

      // Vérification que l'utilisateur a bien été créé
      if (user == null) {
        return 'User creation failed';
      }

      // Téléchargement de l'image de profil et récupération de l'URL
      String photoUrl = await StorageMethods().uploadImageToStorage(
        false,
        'profilePics',
        file,
      );

      // Création d'une nouvelle instance d'utilisateur avec les informations fournies
      Users newUser = Users(
        uid: user.uid,
        email: email,
        username: username,
        bio: '',
        photoUrl: photoUrl,
        followers: [],
        following: [],
        posts: [],
        saved: [],
        searchKey: username[0].toUpperCase(),
      );

      // Enregistrement de l'utilisateur dans la collection Firestore
      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

      return 'success';
    } catch (e) {
      // En cas d'erreur, retourne le message d'erreur
      return e.toString();
    }
  }

  // Méthode pour obtenir les détails de l'utilisateur actuellement connecté
  Future<Users> getUserDetails() async {
    User? currentUser = _auth.currentUser;

    // Vérification qu'un utilisateur est actuellement connecté
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    // Récupération des informations de l'utilisateur depuis Firestore
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    if (snap.data() == null) {
      throw Exception('User data is null');
    }
    
    // Conversion des données en instance d'utilisateur
    return Users.fromSnap(snap);
  }
}
