import 'package:airbnb/CustomWidgets/ListTiles.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/AppScreens/ConversationPage.dart';
import 'package:airbnb/Models/Conversations.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyInboxPage extends StatefulWidget {

  MyInboxPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyInboxPageState createState() => _MyInboxPageState();

}

class InboxPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MyInboxPage(title: AppConstants.appName);
  }
}

class _MyInboxPageState extends State<MyInboxPage> {

  void _navigateToConversation(Conversation conversation) {
    Navigator.pushNamed(
      context,
      ConversationPage.routeName,
      arguments: conversation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.smallPadding,
        AppConstants.smallPadding,
        AppConstants.smallPadding,
        0.0,
      ),
      child: StreamBuilder(
        stream: Firestore.instance.collection(
            'conversations').where('userIDs', arrayContains: AppConstants.currentUser.id).snapshots(),
        builder: (context, snapshots) {
          switch (snapshots.connectionState) {
            case ConnectionState.waiting:
              return new Center(child: new CircularProgressIndicator());
            default:
              return ListView.builder(
                itemExtent: MediaQuery.of(context).size.height / 7,
                itemCount: snapshots.data.documents.length,
                itemBuilder: (context, index) {
                  Conversation conversation = Conversation();
                  conversation.loadConversationFromFirestore(snapshots.data.documents[index]);
                  return GestureDetector(
                    child: ConversationListTile(conversation: conversation),
                    onTap: () {
                      _navigateToConversation(conversation);
                    },
                  );
                },
              );
          }
        },
      ),

    );
  }
}