import 'dart:io';

import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Reviews.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Conversations.dart';

class Posting {

  String id;
  String name;
  String type;
  double price;
  double rating;
  String location;
  List<String> _imageNames;
  List<MemoryImage> postingImages;
  String description;
  String address;
  Contact host;
  int numGuests;

  Map<String, int> bedroomTypes;
  Map<String, int> bathroomTypes;
  List<Review> reviews;
  List<String> amenities;
  List<Booking> bookings;

  Posting() {
    this.numGuests = 0;
    this.reviews = [];
    this._imageNames = [];
    this.postingImages = [];
    this.bookings = [];
  }

  void getInfoFromDatabase(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    this.name = snapshot['name'];
    this.type = snapshot['type'];
    this.price = snapshot['price'].toDouble();
    this.rating = snapshot['rating'].toDouble();
    this.location = snapshot['city'] + ", " + snapshot['country'];
    this._imageNames = List<String>.from(snapshot['imageNames']);
    this.address = snapshot['address'];
    this.description = snapshot['description'];

    this.bathroomTypes = Map<String, int>.from(snapshot['bathrooms']);
    this.bedroomTypes = Map<String, int>.from(snapshot['beds']);
    this.amenities = List<String>.from(snapshot['amenities']);

    getNumGuests();

    String hostID = snapshot['hostID'];
    this.host = Contact(id: hostID);
  }

  Future<MemoryImage> loadFirstImageFromDatabase() async {
    if (this._imageNames.isEmpty) { return null; }
    if (this.postingImages.isNotEmpty) {
      return this.postingImages.first;
    }
    final bucketRef = FirebaseStorage.instance.ref().child('homesImages').child(id);
    final someData = await bucketRef.child(this._imageNames.first).getData(1024*1024);
    MemoryImage image = MemoryImage(someData);

    print("First posting image loaded");
    print("${someData.length} bytes in size");
    this.postingImages.add(image);
    return image;
  }
  Future<List<MemoryImage>> loadImagesFromDatabase() async {
    final bucketRef = FirebaseStorage.instance.ref().child('homesImages').child(id);
    List<MemoryImage> images = [];
    for(int i = 0; i < _imageNames.length; i++) {
      final imageData = await bucketRef.child(_imageNames[i]).getData(1024*1024);
      images.add(MemoryImage(imageData));
    }
    this.postingImages = images;
    return images;
  }

  String getBedroomText() {
    String text = "";
    if (this.bedroomTypes['small'] != 0) {
      text += this.bedroomTypes['small'].toString() + " single/twin ";
    }
    if (this.bedroomTypes['medium'] != 0) {
      text += this.bedroomTypes['medium'].toString() + " double ";
    }
    if (this.bedroomTypes['large'] != 0) {
      text += this.bedroomTypes['large'].toString() + " queen/king";
    }
    return text;
  }

  String getBathroomText() {
    String text = "";
    if (this.bathroomTypes['full'] != 0) {
      text += this.bathroomTypes['full'].toString() + " full ";
    }
    if (this.bathroomTypes['half'] != 0) {
      text += this.bathroomTypes['half'].toString() + " half";
    }
    return text;
  }

  String getFullAddress() {
    return this.address + ", " + this.location;
  }

  void getNumGuests() {
    this.numGuests = 0;
    this.numGuests += this.bedroomTypes['small'];
    this.numGuests += this.bedroomTypes['medium'];
    this.numGuests += this.bedroomTypes['large'] * 2;
  }

  void addReview(Review review) {
    this.reviews.add(review);
    Firestore.instance.collection("homes/${this.id}/reviews").add(review.getReviewData());

    double reviewAverage = 0.0;
    this.reviews.forEach((review) {
      reviewAverage += review.rating;
    });
    reviewAverage /= this.reviews.length;
    Firestore.instance.document("homes/${this.id}").updateData({
      "rating": reviewAverage,
    });
  }

  Future<String> savePostingToFirestore() async {
    Map<String, dynamic> data = {
      'address': this.address,
      'amenities': this.amenities,
      'bathrooms': {
        'full': this.bathroomTypes['full'],
        'half': this.bathroomTypes['half'],
      },
      'beds': {
        'large': this.bedroomTypes['large'],
        'medium': this.bedroomTypes['medium'],
        'small': this.bedroomTypes['small'],
      },
      'city': this.location.split(', ')[0],
      'county': this.location.split(', ')[1],
      'description': this.description,
      'hostID': AppConstants.currentUser.id,
      'imageNames': this._imageNames,
      'name': this.name,
      'price': this.price,
      'rating': this.rating ?? 0,
      'type': this.type,
    };

    if (this.id == null) {
      DocumentReference ref = await Firestore.instance.collection("homes").add(data);
      this.id = ref.documentID;
      return this.id;
    } else {
      await Firestore.instance.document("homes/${this.id}").updateData(data);
      return this.id;
    }
  }

  Future<void> saveImages() async {
    List<String> imageNames = [];
    for (int i = 0; i < this.postingImages.length; i++) {
      StorageReference ref = FirebaseStorage.instance.ref().child("homesImages/${this.id}/pic$i.png");
      ref.putData(this.postingImages[i].bytes).onComplete;
      imageNames.add('pic$i.png');
    }

    this._imageNames = imageNames;
    await Firestore.instance.document("homes/${this.id}").updateData({
      "imageNames": imageNames,
    });
  }

  String getAmenitiesString() {
    if (this.amenities.isEmpty) { return ""; }
    String amenitiesString = this.amenities.toString();
    return amenitiesString.substring(1, amenitiesString.length - 1);
  }

  Future<void> loadBookings() async {
    this.bookings = [];
    await Firestore.instance.collection('homes/${this.id}/bookings').getDocuments().then((snapshots){
      snapshots.documents.forEach((documentSnapshot) {
        Booking booking = Booking();
        booking._loadBookingFromFirestore(documentSnapshot, this);
        print('loading a booking with id: ${booking.id}');
        this.bookings.add(booking);
      });
    });
  }

  void makeBooking(List<DateTime> dates) async {
    await Firestore.instance.collection('homes/${this.id}/bookings').add({
      'guestID': AppConstants.currentUser.id,
      'dates': dates,
    });

    final Message message = Message();
    String firstDate = dates.first.toString().substring(0,10);
    message.createMessageWithText('Hi ${this.host.firstName}! My name is ${AppConstants.currentUser.firstName} '
        'and I just booked ${this.name} from ${dates.first.toString().substring(0,10)} to '
        '${dates.last.toString().substring(0,10)}. Let me know if you have any'
        'questions or would like to know more about me!');
    DocumentReference convoRef = await Firestore.instance.collection('conversations').add({
      'userIDs': [AppConstants.currentUser.id, this.host.id]
    });
    await message.saveMessageToFirestore(convoRef.documentID);
    AppConstants.currentUser.makeBooking(this.id, dates);
  }

}

class Trip {

  Posting posting;
  DateTime startDate;
  DateTime endDate;

}

class Booking {

  String id;
  List<DateTime> dates;
  Contact contact;
  Posting posting;

  Booking();

  void _loadBookingFromFirestore(DocumentSnapshot snapshot, Posting posting) {
    this.id = snapshot.documentID;
    this.dates = [];
    List<Timestamp> timeStamps = List<Timestamp>.from(snapshot['dates']);
    timeStamps.forEach((timestamp) {
      this.dates.add(timestamp.toDate());
    });
    this.contact = Contact();
    this.contact.id = snapshot['guestID'];
    this.posting = posting;
  }

}