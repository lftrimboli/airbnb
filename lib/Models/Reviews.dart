import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {

  Contact contact;
  String text;
  double rating;
  DateTime dateTime;

  Review();

  void getReviewFromDatabase(DocumentSnapshot snapshot) {
    String imagePath = snapshot['imagePath'];
    String fullName = snapshot['name'];
    this.rating = snapshot['rating'].toDouble();
    this.text = snapshot['text'];
    String userID = snapshot['userID'];
    Timestamp timestamp = snapshot['dateTime'];
    int milliseconds = timestamp.millisecondsSinceEpoch;
    this.dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    this.contact = Contact(fullName: fullName, id: userID, imagePath: imagePath);
  }

  void createReview(double rating, String text, Contact contact, DateTime dateTime) {
    this.rating = rating;
    this.text = text;
    this.contact = contact;
    this.dateTime = dateTime;
  }

  Map<String, dynamic> getReviewData() {
    return {
      'imagePath': this.contact.imagePath,
      'name': this.contact.fullName,
      'rating': this.rating,
      'text': this.text,
      'userID': this.contact.id,
      'dateTime': this.dateTime,
    };
  }


}