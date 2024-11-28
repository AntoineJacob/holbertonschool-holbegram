import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holbegram/screens/pages/methods/post_storage.dart';
import 'package:holbegram/widgets/bottom_nav.dart';

// Classe principale de l'écran pour ajouter une image
class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  AddImageState createState() => AddImageState();
}

// État associé à la classe AddImage
class AddImageState extends State<AddImage> {
  Uint8List? _image;
  bool _isLoading = false;
  final TextEditingController _captionController = TextEditingController();

  String? username;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Récupère les données de l'utilisateur actuel
  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = userDoc['username'];
        profileImageUrl = userDoc['photoUrl'];
      });
    }
  }

  // Affiche une feuille de modal pour sélectionner une image
  void selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                Uint8List image = await pickImage(ImageSource.gallery);
                if (mounted) {
                  setState(() {
                    _image = image;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                Uint8List image = await pickImage(ImageSource.camera);
                if (mounted) {
                  setState(() {
                    _image = image;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Sélectionne une image à partir de la source spécifiée (galerie ou appareil photo)
  Future<Uint8List> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    } else {
      throw 'No image selected';
    }
  }

  // Télécharge le post avec l'image et la légende
  Future<void> uploadPost() async {
    if (_image == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Récupère l'utilisateur actuel et les données de l'utilisateur
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && username != null && profileImageUrl != null) {
        String res = await PostStorage().uploadPost(
          _captionController.text,
          user.uid,
          username!,
          profileImageUrl!,
          _image!,
        );

        // Met à jour l'état de l'écran et affiche un message en fonction du résultat
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (res == 'Ok') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post uploaded successfully')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const BottomNav()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res)),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Affiche un message en cas d'erreur lors de l'upload
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: Column(
          children: [
            const SizedBox(height: 28),
            AppBar(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Image',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Billabong',
                      fontSize: 35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.red))
                      : IconButton(
                          icon: const Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Billabong',
                              fontSize: 35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: uploadPost,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.04),
                  const Center(
                    child: Text(
                      'Add Image',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Choose an image from your gallery or take a one.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextField(
                    controller: _captionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Center(
                    child: GestureDetector(
                      onTap: selectImage,
                      child: Container(
                        height: screenHeight * 0.3,
                        width: screenWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _image != null
                            ? Image.memory(_image!, fit: BoxFit.cover)
                            : Image.asset(
                                'assets/images/add-img.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}