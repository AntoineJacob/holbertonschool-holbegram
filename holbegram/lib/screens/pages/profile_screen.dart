import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:holbegram/screens/login_screen.dart';
import 'package:holbegram/screens/Pages/edit_profile_screen.dart';

// Classe principale de l'écran de profil utilisateur
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

// État associé à la classe ProfileScreen
class ProfileScreenState extends State<ProfileScreen> {
  // Variables pour stocker les données utilisateur et les statistiques
  Map<String, dynamic> userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Fonction pour récupérer les données de l'utilisateur et les statistiques depuis Firestore
  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Récupère les données utilisateur
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      userData = userSnap.data()!.cast<String, dynamic>();

      // Récupère le nombre de posts de l'utilisateur
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      postLen = postSnap.docs.length;

      // Récupère le nombre de followers de l'utilisateur
      var followersSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userData['uid'])
          .collection('followers')
          .get();
      followers = followersSnap.docs.length;

      // Récupère le nombre de personnes que l'utilisateur suit
      var followingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userData['uid'])
          .collection('following')
          .get();
      following = followingSnap.docs.length;

      setState(() {});
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 28),
                ),
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: const FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 16, bottom: 16),
                    title: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Billabong',
                          fontSize: 25,
                        ),
                      ),
                    ),
                    centerTitle: false,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                  expandedHeight: 75,
                ),
                // Affiche les informations de profil de l'utilisateur
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: Text('User data not found.'));
                        }

                        // Récupère les données utilisateur depuis Firestore
                        userData = snapshot.data!.data() as Map<String, dynamic>;

                        // Affiche les informations de profil de l'utilisateur
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(userData['photoUrl']),
                                      radius: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      userData['username'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  // Affiche les statistiques de l'utilisateur (nombre de posts, followers, following)
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildStatColumn(postLen, "posts"),
                                      buildStatColumn(followers, "followers"),
                                      buildStatColumn(following, "following"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Affiche la bio de l'utilisateur et un bouton pour modifier le profil
                            Text(
                              userData['bio'],
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 159, 91, 171),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditProfileScreen(userData: userData),
                                        ),
                                      );
                                      // Met à jour les données après le retour de l'écran de modification de profil
                                      getData();
                                    },
                                    child: const Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  sliver: SliverFillRemaining(
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

                            return Container(
                              child: Image(
                                image: NetworkImage(snap['postUrl']),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  // Fonction pour créer une colonne de statistique (nombre de posts, followers, following)
  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}