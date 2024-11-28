import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:holbegram/screens/login_screen.dart';

// Classe principale de l'écran d'édition de profil
class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

// État associé à la classe EditProfileScreen
class EditProfileScreenState extends State<EditProfileScreen> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les données utilisateur
    _usernameController.text = widget.userData['username'];
    _bioController.text = widget.userData['bio'];
  }

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs
    _usernameController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Méthode pour mettre à jour le profil utilisateur
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Mettre à jour le mot de passe si un nouveau mot de passe est fourni
      if (_newPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text != _confirmPasswordController.text) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New password and confirmation do not match')),
          );
          return;
        }

        String email = user!.email!;
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: _currentPasswordController.text);
        await user.updatePassword(_newPasswordController.text);
      }

      String photoUrl = widget.userData['photoUrl'];
      // Mettre à jour la photo de profil si une nouvelle image est sélectionnée
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pics').child('${user!.uid}.jpg');
        await storageRef.putFile(_image!);
        photoUrl = await storageRef.getDownloadURL();
      }

      // Mettre à jour les informations utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'username': _usernameController.text,
        'bio': _bioController.text,
        'photoUrl': photoUrl,
      });

      // Mettre à jour les documents de publication avec la nouvelle image de profil et le nouveau nom d'utilisateur
      var postDocs = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: user.uid)
          .get();

      for (var doc in postDocs.docs) {
        await doc.reference.update({
          'profImage': photoUrl,
          'username': _usernameController.text,
        });
      }

      // Naviguer en arrière après la mise à jour du profil
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Méthode pour sélectionner une image de la galerie
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Méthode pour supprimer le compte utilisateur
  Future<void> _deleteAccount() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
        await user.delete();

        // Rediriger vers l'écran de connexion après la suppression du compte
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAccount,
          ),
        ],
      ),
      // Affiche un indicateur de chargement ou le formulaire d'édition de profil
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                children: [
                  const SizedBox(height: 44),
                   // Afficher l'image de profil
                  _buildProfileImage(),
                  const SizedBox(height: 54),
                  // Champ de texte pour le nom d'utilisateur
                  _buildTextField(_usernameController, 'Username', Icons.person),
                  const SizedBox(height: 26),
                   // Champ de texte pour la bio
                  _buildTextField(_bioController, 'Bio', Icons.info),
                  const SizedBox(height: 26),
                  // Champ de texte pour le mot de passe actuel
                  _buildTextField(_currentPasswordController, 'Current Password', Icons.lock, obscureText: true),
                  const SizedBox(height: 26),
                   // Champ de texte pour le nouveau mot de passe
                  _buildTextField(_newPasswordController, 'New Password', Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 26),
                  // Champ de texte pour la confirmation du mot de passe
                  _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 72),
                  SizedBox(
                    width: double.infinity,
                    // Bouton pour mettre à jour le profil
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 159, 91, 171),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget pour afficher et mettre à jour l'image de profil
  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _image != null ? FileImage(_image!) : NetworkImage(widget.userData['photoUrl']) as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 7,
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _pickImage,
          ),
        ),
        if (_isLoading)
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }

  // Widget pour construire un champ de texte avec des paramètres spécifiques
  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}