import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Fonction pour vérifier si une clé existe dans les données du document
bool containsKey(DocumentSnapshot doc, String key) {
  final data = doc.data() as Map<String, dynamic>?;
  return data != null && data.containsKey(key);
}

// Widget Posts, affichant les posts de l'utilisateur récupérés depuis la base de données
class Posts extends StatelessWidget {
  final String? filterUid;
  const Posts({super.key, this.filterUid});

  @override
  Widget build(BuildContext context) {
    // Récupération des posts depuis la base de données
    return StreamBuilder(
      stream: (filterUid == null)
          ? FirebaseFirestore.instance
              .collection('posts')
              .orderBy('datePublished', descending: true)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('posts')
              .where('uid', isEqualTo: filterUid)
              .orderBy('datePublished', descending: true)
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Récupération des données de la collection 'posts'
        final data = snapshot.requireData;

        // Affichage des posts de l'utilisateur
        return ListView.builder(
          padding: const EdgeInsets.only(top: 30),
          itemCount: data.size,
          itemBuilder: (context, index) {
            var post = data.docs[index];
            String postUrl = post['postUrl'] ?? '';
            String profImage = post['profImage'] ?? '';
            String username = post['username'] ?? 'Anonymous';
            String caption = post['caption'] ?? '';
            String postId = post.id;

            // Récupération du nombre de likes
            int likesCount = (post['likes'] is List) ? post['likes'].length : post['likes'] ?? 0;
            String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

            // Affichage du post
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(profImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(username),
                      const Spacer(),
                      if (currentUserId == post['uid'])
                        IconButton(
                          icon: const Icon(Icons.more_horiz),
                          onPressed: () async {
                            final action = await showDialog<PostAction>(
                              context: context,
                              builder: (BuildContext context) {
                                // Boîte de dialogue pour choisir une action à effectuer sur le post
                                return AlertDialog(
                                  title: const Center(child: Text('Choose an action')),
                                  content: const Text('Select an action to perform on this post'),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(PostAction.delete),
                                          child: const Text('Delete'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(PostAction.edit),
                                          child: const Text('Edit'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(null),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                            // Exécution de l'action sélectionnée sur le post
                            if (action == PostAction.delete) {
                              bool? deleteConfirmed = await showDialog(
                                // ignore: use_build_context_synchronously
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text('Are you sure you want to delete this post?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Suppression du post de la base de données
                              if (deleteConfirmed == true) {
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId)
                                    .delete();
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Post Deleted')),
                                );
                              }
                            // Modification du post dans la base de données
                            } else if (action == PostAction.edit) {
                              await showDialog(
                                // ignore: use_build_context_synchronously
                                context: context,
                                builder: (BuildContext context) {
                                  TextEditingController captionController = TextEditingController(text: caption);
                                  return AlertDialog(
                                    title: const Text('Edit Post'),
                                    content: TextField(
                                      controller: captionController,
                                      decoration: const InputDecoration(hintText: 'Enter new caption'),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(postId)
                                              .update({'caption': captionController.text});
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Post Updated')),
                                          );
                                        },
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Affichage de la légende du post
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(caption),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  // Affichage de l'image du post ou du post partagé
                  if (containsKey(post, 'sharedFrom')) ...[
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(post['sharedFrom']['profImage']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(post['sharedFrom']['username']),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post['sharedFrom']['caption']),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(post['sharedFrom']['postUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Affichage de l'image du post
                    Center(
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(postUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FavoriteIconButton(postId: post.id, likes: likesCount),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () => sendMessageToUser(context, post),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => sharePost(context, post),
                      ),
                      const Spacer(),
                      if (currentUserId != post['uid'])
                        FollowButton(postUid: post['uid']),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$likesCount Liked',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Fonction pour partager un post avec un autre utilisateur
  void sharePost(BuildContext context, QueryDocumentSnapshot post) async {
    TextEditingController captionController = TextEditingController();

    // Boîte de dialogue pour partager un post avec un autre utilisateur
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Post'),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(hintText: 'Enter a caption'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                String username = userSnapshot.get('username');
                String profImage = userSnapshot.get('photoUrl');

                await FirebaseFirestore.instance.collection('posts').add({
                  'uid': user.uid,
                  'username': username,
                  'profImage': profImage,
                  'postUrl': post['postUrl'],
                  'caption': captionController.text,
                  'datePublished': Timestamp.now(),
                  'likes': [],
                  'sharedFrom': {
                    'username': post['username'],
                    'profImage': post['profImage'],
                    'caption': post['caption'],
                    'postUrl': post['postUrl'],
                  },
                });

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post shared successfully')),
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  // Fonction pour envoyer un message à un autre utilisateur
  void sendMessageToUser(BuildContext context, QueryDocumentSnapshot post) async {
    TextEditingController messageController = TextEditingController();
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Boîte de dialogue pour envoyer un message à un autre utilisateur
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(hintText: 'Enter your message'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (currentUser != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(post['uid'])
                    .collection('messages')
                    .add({
                  'senderId': currentUser.uid,
                  'content': messageController.text,
                  'timestamp': Timestamp.now(),
                  'read': false,
                });

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent successfully')),
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

// Enum for post actions
enum PostAction { delete, edit }

// Widget FavoriteIconButton, permettant à l'utilisateur de marquer un post comme favori
class FavoriteIconButton extends StatefulWidget {
  final String postId;
  final int likes;
  const FavoriteIconButton({required this.postId, required this.likes, super.key});

  @override
  FavoriteIconButtonState createState() => FavoriteIconButtonState();
}

// Classe State associée au widget FavoriteIconButton
class FavoriteIconButtonState extends State<FavoriteIconButton> {
  bool isFavorited = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    likesCount = widget.likes;
    checkIfFavorited();
  }

  // Vérification si le post est déjà marqué comme favori
  void checkIfFavorited() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.postId)
          .get();
      if (mounted) {
        setState(() {
          isFavorited = doc.exists;
        });
      }
    }
  }

  // Fonction pour marquer/démarquer un post comme favori
  void toggleFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference favRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.postId);

      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId);

      if (isFavorited) {
        if (likesCount > 0) {
          await favRef.delete();
          await postRef.update({'likes': FieldValue.increment(-1)});
          if (mounted) {
            setState(() {
              isFavorited = false;
              likesCount--;
            });
          }
        }
      } else {
        await favRef.set({'postId': widget.postId});
        await postRef.update({'likes': FieldValue.increment(1)});
        if (mounted) {
          setState(() {
            isFavorited = true;
            likesCount++;
          });
        }
      }
    }
  }

  // Affichage du bouton de favori
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_outline,
        color: isFavorited ? Colors.red : null,
      ),
      onPressed: toggleFavorite,
    );
  }
}

// Widget FollowButton, permettant à l'utilisateur de suivre ou de ne pas suivre un autre utilisateur
class FollowButton extends StatefulWidget {
  final String postUid;
  const FollowButton({required this.postUid, super.key});

  @override
  FollowButtonState createState() => FollowButtonState();
}

class FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  // Vérification si l'utilisateur suit déjà l'autre utilisateur
  void checkIfFollowing() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(widget.postUid)
          .get();
      if (mounted) {
        setState(() {
          isFollowing = doc.exists;
        });
      }
    }
  }

  // Fonction pour suivre/désabonner un autre utilisateur
  void toggleFollow() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid != widget.postUid) {
      DocumentReference followingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(widget.postUid);

      DocumentReference followerRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.postUid)
          .collection('followers')
          .doc(user.uid);

      if (isFollowing) {
        await followingRef.delete();
        await followerRef.delete();
        if (mounted) {
          setState(() {
            isFollowing = false;
          });
        }
      } else {
        await followingRef.set({'uid': widget.postUid});
        await followerRef.set({'uid': user.uid});
        if (mounted) {
          setState(() {
            isFollowing = true;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot follow yourself")),
      );
    }
  }

  // Affichage du bouton de suivi
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFollowing ? Icons.bookmark : Icons.bookmark_border,
        color: isFollowing ? Colors.blue : null,
      ),
      onPressed: toggleFollow,
    );
  }
}