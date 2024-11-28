import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Widget Favorite, affichant les posts favoris de l'utilisateur
class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Ajout d'un espace en haut de l'écran
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          // Barre d'application personnalisée
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Container(
              padding: const EdgeInsets.only(bottom: 1.0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Favorites',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Billabong',
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          // Reste de l'écran remplie par le StreamBuilder
          SliverFillRemaining(
            child: StreamBuilder(
              // Écoute des données de la collection 'favorites' de l'utilisateur actuel
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('favorites')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // Gestion des erreurs
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // Affichage d'un cercle de chargement si les données sont en cours de chargement
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Récupération des documents favoris
                final favoriteDocs = snapshot.requireData.docs;

                // Affichage des posts favoris sous forme de liste
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: favoriteDocs.length,
                  itemBuilder: (context, index) {
                    var favoriteDoc = favoriteDocs[index];

                    // FutureBuilder pour récupérer les détails du post favori
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(favoriteDoc['postId'])
                          .get(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> postSnapshot) {
                        // Gestion des erreurs
                        if (postSnapshot.hasError) {
                          return Center(child: Text('Error: ${postSnapshot.error}'));
                        }
                        // Affichage d'un cercle de chargement si les données sont en cours de chargement
                        if (postSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Vérification si le post existe
                        if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                          return Container();
                        }

                        // Récupération des données du post
                        var post = postSnapshot.data!;

                        // Affichage de l'image du post favori
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          height: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(post['postUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}