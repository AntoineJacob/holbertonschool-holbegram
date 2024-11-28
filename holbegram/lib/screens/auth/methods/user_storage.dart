import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Classe pour gérer les méthodes de stockage sur Firebase
class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour uploader une image dans le stockage Firebase
  Future<String> uploadImageToStorage(
    bool isPost,
    String childName,
    Uint8List file,
  ) async {
    // Référence au dossier dans le stockage avec l'ID de l'utilisateur courant
    Reference ref = _storage.ref().child(childName).child(_auth.currentUser!.uid);

    // Si c'est une image de post, ajoute un dossier avec un ID unique
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // Lance l'upload du fichier
    UploadTask uploadTask = ref.putData(file);

    // Attend la fin de l'upload et obtient un snapshot de la tâche
    TaskSnapshot snapshot = await uploadTask;

    // Récupère l'URL de téléchargement de l'image
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // Retourne l'URL de téléchargement
    return downloadUrl;
  }
}