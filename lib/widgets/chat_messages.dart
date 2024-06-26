import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapShot) {
          if (chatSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (!chatSnapShot.hasData || chatSnapShot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found'),
            );
          }
          if (chatSnapShot.hasError) {
            return Center(
              child: Text('Something went wrong'),
            );
          }
          final loadedMessages = chatSnapShot.data!.docs;

          return ListView.builder(
              padding: EdgeInsets.only(bottom: 40, right: 13, left: 13),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessages[index].data();
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;
                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser == currentMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser == currentMessageUserId);
                }
              });
        });
  }
}
