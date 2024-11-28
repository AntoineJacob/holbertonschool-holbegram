import 'package:cloud_firestore/cloud_firestore.dart';

// Classe pour représenter un utilisateur
class Users {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final String photoUrl;
  final List<dynamic> followers;
  final List<dynamic> following;
  final List<dynamic> posts;
  final List<dynamic> saved;
  final String searchKey;

  // Constructeur de la classe Users
  Users({
    required this.uid,
    required this.email,
    required this.username,
    required this.bio,
    required this.photoUrl,
    required this.followers,
    required this.following,
    required this.posts,
    required this.saved,
    required this.searchKey,
  });

  // Méthode pour convertir une instance de Users en une représentation Map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'photoUrl': photoUrl,
      'followers': followers,
      'following': following,
      'posts': posts,
      'saved': saved,
      'searchKey': searchKey,
    };
  }

  // Méthode pour créer une instance de Users à partir d'un DocumentSnapshot
  static Users fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>?;

    // Vérifier si le DocumentSnapshot contient des données
    if (snapshot == null) {
      throw const FormatException("Invalid snapshot data");
    }

    return Users(
      uid: snapshot['uid'] ?? '',
      email: snapshot['email'] ?? '',
      username: snapshot['username'] ?? '',
      bio: snapshot['bio'] ?? '',
      photoUrl: snapshot['photoUrl'] ?? '',
      followers: snapshot['followers'] ?? [],
      following: snapshot['following'] ?? [],
      posts: snapshot['posts'] ?? [],
      saved: snapshot['saved'] ?? [],
      searchKey: snapshot['searchKey'] ?? '',
    );
  }
}