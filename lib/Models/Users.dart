import 'dart:io';
import 'package:airbnb/Models/Conversations.dart';
import 'package:airbnb/Models/OnDeviceDatabaseFunctions.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:airbnb/Models/Reviews.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Contact {

  String id;
  String firstName;
  String lastName;
  String fullName;
  String imagePath;
  MemoryImage displayImage;

  Contact({this.fullName="", this.id="", String imagePath=""}) {
    this.imagePath = imagePath;

    if (fullName.isEmpty) { return; }
    List<String> names = fullName.split(" ");
    this.firstName = names[0];
    this.lastName = names[1];
  }

  void loadUserFromFirestore(DocumentSnapshot snapshot) {
    this.id = snapshot.documentID;
    this.firstName = snapshot['firstName'];
    this.lastName = snapshot['lastName'];
    this.fullName = this.firstName + " " + this.lastName;
    this.imagePath = snapshot['imagePath'];
  }

  String getDatabaseReference() {
    return "users/${this.id}";
  }

  Future<MemoryImage> getImageFromDatabase() async {
    if (this.displayImage != null) { return this.displayImage; }
    final someData = await FirebaseStorage.instance.ref().child(this.imagePath).getData(1024*1024);
    this.displayImage = MemoryImage(someData);
    return MemoryImage(someData);
  }

  User createUserFromContact() {
    User user = User();
    user.id = this.id;
    user.firstName = this.firstName;
    user.lastName = this.lastName;
    user.fullName = this.fullName;
    user.imagePath = this.imagePath;
    user.displayImage = this.displayImage;
    return user;
  }

}

class User extends Contact {

  String email;
  String password;
  String bio;
  String location;
  bool isHost;
  bool isCurrentlyHosting;
  String imagePath;
  MemoryImage displayImage;

  List<Review> reviews;
  List<Trip> previousTrips;
  List<Trip> upcomingTrips;
  List<Posting> savedTrips;
  List<Conversation> conversations;
  List<String> conversationIDs;

  List<Posting> myPostings;
  List<Trip> bookings;

  User() {
    this.isCurrentlyHosting = false;
    this.reviews = [];
    this.previousTrips = [];
    this.upcomingTrips = [];
    this.savedTrips = [];
    this.conversations = [];
    this.conversationIDs = [];

    this.myPostings = [];
    this.bookings = [];
  }
  
  Future<void> getCurrentUserInfo(String email, String password) async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password);
    await Firestore.instance.collection('users').document(firebaseUser.uid).get().then((snapshot) {
      this.loadUserFromFirestore(snapshot);
      this.getSavedTripsFromDatabase(snapshot);
      // TODO load upcoming and previous trips
    });
  }

  void loadUserFromFirestore(DocumentSnapshot snapshot) {
    this.id = snapshot.documentID;
    this.email = snapshot['email'];
    this.firstName = snapshot['firstName'];
    this.lastName = snapshot['lastName'];
    this.fullName = this.firstName + " " + this.lastName;
    this.bio = snapshot['bio'];
    this.location = snapshot['location'];
    this.isHost = snapshot['isHost'];
    this.imagePath = snapshot['imagePath'];
    this.conversationIDs = List<String>.from(snapshot['savedTripIDs']) ?? [];

    this.getSavedTripsFromDatabase(snapshot);
    this.getMyPostingsFromFirestore(snapshot);
  }

  void getSavedTripsFromDatabase(DocumentSnapshot snapshot) {
    List<String> postingIDs = List<String>.from(snapshot['savedTripIDs']) ?? [];
    postingIDs.forEach((id) {
      Firestore.instance.document("homes/$id").get().then((snapshot) {
        Posting posting = Posting();
        posting.getInfoFromDatabase(snapshot);
        this.savedTrips.add(posting);
      });
    });
  }

  void getMyPostingsFromFirestore(DocumentSnapshot snapshot) {
    List<String> postingIDs = List<String>.from(snapshot['postingIDs']) ?? [];
    postingIDs.forEach((postingID) {
      Firestore.instance.document("homes/$postingID").get().then((snapshot) {
        Posting posting = Posting();
        posting.getInfoFromDatabase(snapshot);
        this.myPostings.add(posting);
      });
    });
  }

  Future<void> addToFirestore() async {
    await Firestore.instance.document("users/${this.id}").setData({
      "bio": this.bio,
      "email": this.email,
      "firstName": this.firstName,
      "imagePath": "",
      "isHost": false,
      "lastName": this.lastName,
      "location": this.location,
      "savedTripIDs": []
    });
    // TODO add the reviews, upcoming trips, and previous trips
  }

  Future<void> saveToFirestore() async {
    List<String> savedTripIDs = [];
    this.savedTrips.forEach((trip) {
      savedTripIDs.add(trip.id);
    });
    await Firestore.instance.document("users/${this.id}").setData({
      "bio": this.bio,
      "email": this.email,
      "firstName": this.firstName,
      "imagePath": this.imagePath,
      "isHost": this.isHost,
      "lastName": this.lastName,
      "location": this.location,
      "savedTripIDs": savedTripIDs,
    });
  }

  Contact createContactFromUser() {
    Contact contact = Contact(fullName: this.fullName, id: this.id, imagePath: this.imagePath);
    contact.displayImage = this.displayImage;
    return contact;
  }

  void addPostingToSaved(Posting posting) {
    this.savedTrips.add(posting);
    _updateSavedTrips();
  }

  void removePostingFromSaved(Posting posting) {
    for(int i = 0; i < this.savedTrips.length; i++) {
      if (this.savedTrips[i].id == posting.id) {
        this.savedTrips.removeAt(i);
        break;
      }
    }
    _updateSavedTrips();
  }

  void _updateSavedTrips() {
    List<String> savedTripIDs = [];
    this.savedTrips.forEach((trip) {
      savedTripIDs.add(trip.id);
    });
    Firestore.instance.document("users/${this.id}").updateData({
      "savedTripIDs": savedTripIDs
    });
  }

  void addReview(Review review) {
    this.reviews.add(review);
    Firestore.instance.collection("users/${this.id}/reviews").add(review.getReviewData());
  }

  void becomeAHost() async {
    this.isHost = true;
    changeHosting(true);
    await Firestore.instance.document("users/${this.id}").updateData({
      "isHost": true,
    });
  }

  void changeHosting(bool isHosting) {
    this.isCurrentlyHosting = isHosting;
    UserLoginFunctions.saveUserInfo();
  }

  Future<void> saveImageToFirebase(File imageFile) async {
    StorageReference ref = FirebaseStorage.instance.ref().child("userImages/${this.id}/profile_pic.png");
    await ref.putFile(imageFile).onComplete;
    this.imagePath = "userImages/${this.id}/profile_pic.png";
    Firestore.instance.document("users/${this.id}").updateData({
      "imagePath": this.imagePath,
    });
    this.displayImage = MemoryImage(await imageFile.readAsBytes());
  }

  void savePostingToMyPostings(Posting posting) {
    List<String> postingIDs = [];
    this.myPostings.forEach((post) {
      postingIDs.add(post.id);
    });
    if (!postingIDs.contains(posting.id)) {
      this.myPostings.add(posting);
      postingIDs.add(posting.id);
      Firestore.instance.document("users/${this.id}").updateData({
        'postingIDs': postingIDs
      });
    } else {
      this.myPostings[postingIDs.indexOf(posting.id)] = posting;
    }
  }

  void makeBooking(String postingID, List<DateTime> dates) async {
    await Firestore.instance.collection('users/${this.id}/bookings').add({
      'dates': dates,
      'postingID': postingID,
    });
  }

}
