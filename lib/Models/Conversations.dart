import 'package:airbnb/Models/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppConstants.dart';

class Conversation {

  DocumentReference ref;
  String id;
  Contact otherContact;
  List<Message> messages;
  Message lastMessage;

  Conversation() {
    messages = [];
  }

  void loadConversationFromFirestore(DocumentSnapshot snapshot) {
    this.id = snapshot.documentID;
    this.ref = snapshot.reference;
    List<String> userIDs = List<String>.from(snapshot['userIDs']) ?? [];
    if (userIDs[0] == AppConstants.currentUser.id) {
      otherContact = Contact(id: userIDs[1]);
    } else if (userIDs[1] == AppConstants.currentUser.id) {
      otherContact = Contact(id: userIDs[0]);
    }

    String lastMessageText = snapshot['lastText'];
    Timestamp timestamp = snapshot['lastDateTime'];
    int milliseconds = timestamp.millisecondsSinceEpoch;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    this.lastMessage = Message();
    this.lastMessage.text = lastMessageText;
    this.lastMessage.dateTime = dateTime;
  }

  String getLastMessageText() {
    if (messages.isEmpty) {
      return "";
    }
    return messages.last.text;
  }

  String getLastMessageDateTime() {
    if (messages.isEmpty) {
      return "";
    }
    return messages.last.getMessageDateTime();
  }

}

class Message {

  String senderID;
  Contact contact;
  String text;
  DateTime dateTime;

  Message();

  void createMessageWithText(String text) {
    this.text = text;
    this.contact = AppConstants.currentUser.createContactFromUser();
    this.senderID = contact.id;
    this.dateTime = DateTime.now();
  }

  void loadMessageFromFirestore(DocumentSnapshot snapshot) {
    this.text = snapshot['text'];
    this.senderID = snapshot['senderID'];
    Timestamp timestamp = snapshot['dateTime'];
    if (this.senderID == AppConstants.currentUser.id) {
      this.contact = AppConstants.currentUser.createContactFromUser();
    }
    int milliseconds = timestamp.millisecondsSinceEpoch;
    this.dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  void assignContact(Contact otherContact) {
    if (this.senderID == AppConstants.currentUser.id) {
      this.contact = AppConstants.currentUser.createContactFromUser();
    } else {
      this.contact = otherContact;
    }
  }

  String getMessageDateTime() {
    final DateTime now = DateTime.now();
    final int today = now.day;
    if (dateTime.day != today) {
      return _getDate(dateTime.toIso8601String().substring(5, 10));
    } else {
      return _getTime(dateTime.toIso8601String().substring(11, 16));
    }
  }

  String _getDate(String fullDate) {
    String month = AppConstants.months[fullDate.substring(0, 2)] + " ";
    String day = fullDate.substring(3, 5);
    if (day.substring(0, 1) == "0") {
      day = day.substring(1, 2);
    }
    return month + day;
  }

  String _getTime(String fullTime) {
    String hours = fullTime.substring(0,2);
    int hoursInt = int.parse(hours);
    if (hoursInt > 12) {
      hours = (hoursInt - 12).toString();
    }
    return hours + fullTime.substring(2);
  }

  Future<void> saveMessageToFirestore(String convoID) async {
    await Firestore.instance.collection("conversations/$convoID/messages").add({
      'dateTime': this.dateTime,
      'senderID': AppConstants.currentUser.id,
      'text': this.text
    });
    await Firestore.instance.document("conversations/$convoID").updateData({
      'lastDateTime': this.dateTime,
      'lastText': this.text
    });

  }

}