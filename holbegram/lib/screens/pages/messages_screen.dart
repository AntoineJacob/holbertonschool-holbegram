import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Classe principale pour l'écran des messages
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  MessagesScreenState createState() => MessagesScreenState();
}

// État de l'écran des messages
class MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // StreamBuilder pour afficher les messages de l'utilisateur
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Récupérer les messages de l'utilisateur
          final messages = snapshot.data!.docs;

          // Si l'utilisateur n'a pas de messages à afficher
          if (messages.isEmpty) {
            return const Center(
              child: Text(
                'No messages available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Afficher les messages de l'utilisateur
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return MessageTile(message: message);
            },
          );
        },
      ),
    );
  }
}

// Classe pour afficher un message
class MessageTile extends StatelessWidget {
  final QueryDocumentSnapshot message;
  const MessageTile({super.key, required this.message});

  void deleteMessage(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('messages')
        .doc(message.id)
        .delete();

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message deleted')),
    );
  }

  // Fonction pour répondre à un message
  void replyToMessage(BuildContext context, String senderId) async {
    TextEditingController replyController = TextEditingController();

    // Afficher une boîte de dialogue pour répondre au message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Message'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'Enter your reply'),
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
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(senderId)
                    .collection('messages')
                    .add({
                  'senderId': currentUser.uid,
                  'content': replyController.text,
                  'timestamp': Timestamp.now(),
                  'read': false,
                });

                // Afficher un message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply sent successfully')),
                );

                // Fermer la boîte de dialogue
                Navigator.of(context).pop();
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // Afficher les détails du message
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(message['senderId'])
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            title: Text('Anonymous'),
            subtitle: Text('Loading...'),
          );
        }

        // Récupérer les détails de l'expéditeur
        var sender = snapshot.data!.data() as Map<String, dynamic>;
        var senderName = sender['username'];
        var senderPhotoUrl = sender['photoUrl'];

        if (message['read'] == false) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('messages')
              .doc(message.id)
              .update({'read': true});
        }

        // Afficher le message de l'expéditeur avec des options pour répondre et supprimer
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 45.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(senderPhotoUrl),
              ),
              title: Text(senderName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(message['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.reply, color: Colors.blue),
                    onPressed: () =>
                        replyToMessage(context, message['senderId']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteMessage(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}