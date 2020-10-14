import 'package:airbnb/AppScreens/CreatePostingPage.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:flutter/material.dart';

class MyListingsPage extends StatefulWidget {

  MyListingsPage({Key key}) : super(key: key);

  @override
  _MyListingsPageState createState() => _MyListingsPageState();

}

class ListingsPage extends StatelessWidget {

  static final String routeName = '/listingsPageRoute';

  @override
  Widget build(BuildContext context) {
    return MyListingsPage();
  }
}

class _MyListingsPageState extends State<MyListingsPage> {

  List<Posting> _listings;

  void _navigateToViewListing(Posting posting) {
    Navigator.pushNamed(
      context,
      CreatePostingPage.routeName,
      arguments: posting,
    );
  }

  @override
  void initState() {
    _listings = AppConstants.currentUser.myPostings;

    super.initState();
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
            child: HeadingText(text: "Listings"),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _listings.length + 1,
            itemBuilder: (context, index) {
              Posting posting = (index == _listings.length) ? null : _listings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                child: GestureDetector(
                  onTap: () {
                    _navigateToViewListing(posting);
                  },
                  child: Container(
                    child: (posting == null)
                      ? CreateListingTile()
                      : ListingTile(posting: _listings[index]
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey,
                          width: 1.0
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ListingTile extends StatefulWidget {

  final Posting posting;

  ListingTile({Key key, this.posting}) : super(key: key);

  @override
  ListingTileState createState() => ListingTileState();

}

class ListingTileState extends State<ListingTile> {

  MemoryImage _image;

  @override
  void initState() {
    widget.posting.loadFirstImageFromDatabase().then((image) {
      setState(() {
        _image = image;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: AppConstants.tinyPadding),
        child: RegularText(text: widget.posting.name),
      ),
      trailing: AspectRatio(
        aspectRatio: 3/2,
        child: (_image == null)
            ? Container()
            : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _image,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
      ),
      contentPadding: EdgeInsets.all(AppConstants.tinyPadding),
    );
  }

}

class CreateListingTile extends StatelessWidget {

  CreateListingTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: AppConstants.tinyPadding, right: AppConstants.tinyPadding),
            child: Icon(Icons.add),
          ),
          Expanded(child: RegularText(text: "Create another listing"))
        ],
      ),
    );
  }

}
