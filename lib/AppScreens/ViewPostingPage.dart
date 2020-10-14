import 'dart:async';
import 'package:airbnb/AppScreens/BookingPage.dart';
import 'package:airbnb/CustomWidgets/Forms.dart';
import 'package:airbnb/CustomWidgets/ListTiles.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:airbnb/Models/Reviews.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/AppScreens/ViewProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MyViewPostingPage extends StatefulWidget {

  MyViewPostingPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyViewPostingPageState createState() => _MyViewPostingPageState();

}

class ViewPostingPage extends StatelessWidget {

  static const routeName = '/viewPostingPage';

  @override
  Widget build(BuildContext context) {
    return MyViewPostingPage(title: AppConstants.appName);
  }
}

class _MyViewPostingPageState extends State<MyViewPostingPage> {

  Completer<GoogleMapController> _controller;
  static LatLng _center;
  Posting _posting;
  List<MemoryImage> _images = [];

  String _bedroomInfoText;
  String _bathroomInfoText;

  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewProfilePage()),
    );
  }

  void _navigateToBookingPage() {
    Navigator.pushNamed(
      context,
      CalendarPage.routeName,
      arguments: this._posting,
    );
  }

  void _calculateLatLng() {
    _center = LatLng(49.2827, -123.1207);
    Geolocator().placemarkFromAddress(this._posting.getFullAddress()).then((placemarks) {
      placemarks.forEach((placemark) {
        setState(() {
          _center = LatLng(placemark.position.latitude, placemark.position.longitude);
        });
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _savePosting() {
    AppConstants.currentUser.addPostingToSaved(this._posting);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Posting saved!"), duration: Duration(seconds: 1),));
  }

  void _submitReview(Review review) {
    setState(() {
      this._posting.addReview(review);
    });
  }

  @override
  void initState() {
    _bedroomInfoText = "";
    _bathroomInfoText = "";
    _controller = Completer();

    super.initState();
  }

  void _loadPostingInfo() {
    if (this._images.isEmpty) {
      _posting.loadImagesFromDatabase().then((images) {
        setState(() {
          this._images = images;
        });
      });
    } else {
      setState(() {
        this._images = _posting.postingImages;
      });
    }
    Firestore.instance.document("users/${_posting.host.id}").get().then((snapshot) {
      _posting.host.loadUserFromFirestore(snapshot);
      _posting.host.getImageFromDatabase().then((image) {
        setState(() {

        });
      });
    });
    _calculateLatLng();
    setState(() {
      _bedroomInfoText = this._posting.getBedroomText();
      _bathroomInfoText = this._posting.getBathroomText();
    });


  }

  @override
  Widget build(BuildContext context) {

    if (this._posting == null) {
      final Posting posting = ModalRoute.of(context).settings.arguments;
      this._posting = posting;
      _loadPostingInfo();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Posting"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _savePosting();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              child: (_images.isEmpty) ? Container() : PageView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Image(
                    image: _images[index],
                    fit: BoxFit.fill,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.smallPadding,
                AppConstants.smallPadding,
                AppConstants.smallPadding,
                0.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        HeadingText(
                          text: _posting.name,
                          fontSize: AppConstants.largeFontSize,
                        ),
                        MaterialButton(
                          onPressed: _navigateToBookingPage,
                          child: RegularText(text: "Book Now"),
                          color: Colors.redAccent,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RegularText(text: _posting.location),
                            RegularText(text: (_posting.host.fullName == null) ? "" : 'Hosted by ${_posting.host.fullName}'),
                          ],
                        ),
                        RawMaterialButton(
                          onPressed: _navigateToProfilePage,
                          child: CircleAvatar(
                            backgroundImage: _posting.host.displayImage,
                            radius: MediaQuery.of(context).size.width / 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        PostingInfoTile(
                          icon: Icon(Icons.home),
                          category: _posting.type,
                          categoryInfo: "${_posting.numGuests} guests",
                        ),
                        PostingInfoTile(
                          icon: Icon(Icons.hotel),
                          category: "${_posting.bedroomTypes.keys.toList().length} bedrooms",
                          categoryInfo: "$_bedroomInfoText",
                        ),
                        PostingInfoTile(
                          icon: Icon(Icons.wc),
                          category: "${_posting.bathroomTypes.keys.toList().length} bathrooms",
                          categoryInfo: "$_bathroomInfoText",
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: RegularText(text: _posting.description),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, AppConstants.smallPadding, 0.0, AppConstants.smallPadding),
                    child: HeadingText(text: 'Amenities'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: GridView.count(
                      shrinkWrap: true,
                      childAspectRatio: 4/1,
                      crossAxisCount: 2,
                      children: List.generate(_posting.amenities.length, (index) {
                        return RegularText(text: _posting.amenities[index]);
                      }),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: HeadingText(text: "The Location")
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 11.0,
                        ),
                        markers: <Marker> {
                          Marker(
                            markerId: MarkerId("House Location"),
                            position: _center,
                            icon: BitmapDescriptor.defaultMarker,
                          ),
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: HeadingText(text: "Reviews"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.tinyPadding),
                    child: ReviewForm(submitReview: _submitReview),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                    child: StreamBuilder(
                      stream: Firestore.instance.collection(
                          "homes/${_posting.id}/reviews").orderBy('dateTime',
                          descending: true).snapshots(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Center(
                                child: new CircularProgressIndicator());
                          default:
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: ((context, index) {
                                Review review = Review();
                                review.getReviewFromDatabase(snapshot.data.documents[index]);
                                print(review.rating);
                                _posting.reviews.add(review);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppConstants.tinyPadding),
                                  child: ReviewListTile(review: review),
                                );
                              }),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostingInfoTile extends StatelessWidget {

  final Icon icon;
  final String category;
  final String categoryInfo;

  const PostingInfoTile({Key key, this.icon, this.category, this.categoryInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: HeadingText(text: category, fontSize: AppConstants.smallFontSize),
      subtitle: RegularText(text: categoryInfo),
    );
  }

}