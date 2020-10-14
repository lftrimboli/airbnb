import 'dart:async';
import 'package:airbnb/CustomWidgets/ListTiles.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Conversations.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyConversationPage extends StatefulWidget {

  MyConversationPage({Key key}) : super(key: key);

  @override
  _MyConversationPageState createState() => _MyConversationPageState();

}

class ConversationPage extends StatelessWidget {

  static final String routeName = '/conversationPage';

  @override
  Widget build(BuildContext context) {
    return MyConversationPage();
  }
}

class _MyConversationPageState extends State<MyConversationPage> {

  ScrollController _controller = ScrollController();
  GlobalKey _textFieldKey = GlobalKey();

  final myController = TextEditingController();
  double _buttonHeight = 55.0;
  String _messageText = "";

  Conversation _conversation;

  void _updateButtonHeight() {
    setState(() {
      _buttonHeight = _textFieldKey.currentContext != null ? _textFieldKey.currentContext.size.height : 50;
    });
  }

  void _sendMessage() {
    if (_messageText.isEmpty) { return; }
    setState(() {
      Message newMessage = Message();
      newMessage.createMessageWithText(this._messageText);
      newMessage.saveMessageToFirestore(this._conversation.id).whenComplete(() {
        setState(() {
        });
      });

      _messageText = "";
      myController.clear();
      _buttonHeight = 55;
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  @override
  Widget build(BuildContext context) {
//    Timer(Duration(milliseconds: 100), () => _controller.jumpTo(_controller.position.maxScrollExtent));
    this._conversation = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(_conversation.otherContact.firstName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppConstants.smallPadding, right: AppConstants.smallPadding),
              child: StreamBuilder(
                stream: _conversation.ref.collection('messages').orderBy('dateTime').snapshots(),
                builder: (context, snapshots) {
                  switch (snapshots.connectionState) {
                    case ConnectionState.waiting:
                      return new Center(child: new CircularProgressIndicator());
                    default:
                      return ListView.builder(
                        controller: _controller,
                        itemCount: snapshots.data.documents.length,
                        itemBuilder: (context, index) {
                          Message message = Message();
                          message.loadMessageFromFirestore(snapshots.data.documents[index]);
                          message.assignContact(_conversation.otherContact);
                          return MessageListTile(message: message);
                        },
                      );
                  }
                },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
            ),
            child: Row (
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 5/6,
                  child: TextField(
                    key: _textFieldKey,
                    controller: myController,
                    onChanged: (text) {
                      _messageText = text;
//                      _updateButtonHeight();
                    },
                    decoration: InputDecoration(
                      hintText: "Write a message",
                      contentPadding: EdgeInsets.all(20.0),
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 5,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    height: 55,
                    onPressed: () {
                      _sendMessage();
                    },
                    child: Text("Send"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}