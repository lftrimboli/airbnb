import 'package:airbnb/AppScreens/ViewProfilePage.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Conversations.dart';
import 'package:airbnb/Models/Reviews.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewListTile extends StatefulWidget {

  final Review review;

  ReviewListTile({Key key, this.review}) : super(key: key);

  @override
  _ReviewListTileState createState() => _ReviewListTileState();

}

class _ReviewListTileState extends State<ReviewListTile> {

  MemoryImage _contactImage;

  void _navigateToProfile(context) {
    Navigator.pushNamed(
      context,
      ViewProfilePage.routeName,
      arguments: widget.review.contact
    );
  }

  void _loadImage() {
    if (widget.review.contact.displayImage != null) {
      _contactImage = widget.review.contact.displayImage;
    } else {
      widget.review.contact.getImageFromDatabase().then((image) {
        setState(() {
          _contactImage = image;
          widget.review.contact.displayImage = image;
        });
      });
    }
  }
  
  @override
  void initState() {
    _loadImage();
    
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                child: CircleAvatar(
                  backgroundImage: _contactImage,
                  radius: MediaQuery.of(context).size.width / 15.0,
                ),
                onTap: () {
                  _navigateToProfile(context);
                },
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(AppConstants.smallPadding, 0.0, 0.0, 0.0),
                  child: HeadingText(
                    text: "${widget.review.contact.fullName}  -  ${widget.review.rating}/5",
                    fontSize: AppConstants.smallFontSize,
                  )
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppConstants.tinyPadding),
            child: RegularText(
              text: widget.review.text,
              fontSize: AppConstants.tinyFontSize,
            ),
          ),
        ],
      ),
    );
  }
  
}


class MessageListTile extends StatelessWidget {

  final Message message;

  MessageListTile({Key key, this.message}): super(key: key);

  void _navigateToProfile(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.contact.fullName == AppConstants.currentUser.fullName) {
      return Padding(
        padding: const EdgeInsets.only(top: AppConstants.tinyPadding, bottom: AppConstants.tinyPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: AppConstants.tinyPadding),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.regularCornerRadius),
                    color: AppConstants.messageBlue,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        message.text,
                        style: TextStyle(
                            fontSize: AppConstants.smallFontSize
                        ),
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppConstants.tinyPadding),
                        child: Text(
                          message.getMessageDateTime(),
                          style: TextStyle(
                              fontSize: AppConstants.tinyFontSize
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
//            GestureDetector(
//              child: CircleAvatar(
//                backgroundImage: message.contact.image,
//                radius: MediaQuery.of(context).size.width / 20.0,
//              ),
//              onTap: () {
//                _navigateToProfile(context);
//              },
//            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: AppConstants.tinyPadding, bottom: AppConstants.tinyPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
//            GestureDetector(
//              child: CircleAvatar(
//                backgroundImage: message.contact.image,
//                radius: MediaQuery.of(context).size.width / 20.0,
//              ),
//              onTap: () {
//                _navigateToProfile(context);
//              },
//            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: AppConstants.tinyPadding),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.regularCornerRadius),
                    color: AppConstants.messageYellow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        message.text,
                        style: TextStyle(
                            fontSize: AppConstants.smallFontSize
                        ),
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppConstants.tinyPadding),
                        child: Text(
                          message.getMessageDateTime(),
//                          message.dateTime.toString(),
                          style: TextStyle(
                              fontSize: AppConstants.tinyFontSize
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

}

class ConversationListTile extends StatefulWidget {

  final Conversation conversation;

  ConversationListTile({Key key, this.conversation}): super(key: key);

  @override
  ConversationListTileState createState() => ConversationListTileState();

}

class ConversationListTileState extends State<ConversationListTile> {

  String firstName = "";

  void _loadContact() {
    Firestore.instance.document("users/${widget.conversation.otherContact.id}").get().then((snapshot){
      widget.conversation.otherContact.loadUserFromFirestore(snapshot);
      widget.conversation.otherContact.getImageFromDatabase().whenComplete((){
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    _loadContact();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      leading: (widget.conversation.otherContact.displayImage == null)
        ? Container(
          width: MediaQuery.of(context).size.width / 13.0,
          height: MediaQuery.of(context).size.width / 13.0,
        )
        : CircleAvatar(
          backgroundImage: widget.conversation.otherContact.displayImage,
          radius: MediaQuery.of(context).size.width / 13.0,
        ),
      title: HeadingText(
        text: widget.conversation.otherContact.firstName ?? "",
        fontSize: 22.5,
      ),
      subtitle: Text(
        widget.conversation.lastMessage.text ?? "",
        style: TextStyle(
          fontSize: AppConstants.smallFontSize,
        ),
        maxLines: 1,
      ),
      trailing: Text(widget.conversation.lastMessage.getMessageDateTime() ?? ""),
      contentPadding: EdgeInsets.only(top: AppConstants.tinyPadding, bottom: AppConstants.tinyPadding),
    );
  }

}

