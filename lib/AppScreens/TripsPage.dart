import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/CustomWidgets/GridTiles.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/AppScreens/ViewPostingPage.dart';
import 'package:flutter/material.dart';

class MyTripsPage extends StatefulWidget {

  MyTripsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyTripsPageState createState() => _MyTripsPageState();

}

class TripsPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyTripsPage(title: AppConstants.appName);
  }
}

class _MyTripsPageState extends State<MyTripsPage> {

  List<Trip> upcomingTripsPostings = [];
  List<Trip> previousTripsPostings = [];

  @override
  void initState() {
    _loadUpcomingTripsPostings();
    _loadPreviousTripsPostings();
    super.initState();
  }

  void _loadUpcomingTripsPostings() {
    setState(() {
      upcomingTripsPostings = AppConstants.currentUser.upcomingTrips;
    });
  }

  void _loadPreviousTripsPostings() {
    setState(() {
      previousTripsPostings = AppConstants.currentUser.previousTrips;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
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
            HeadingText(text: 'Upcoming Trips'),
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.smallPadding, bottom: AppConstants.smallPadding),
              child: Container(
                height: MediaQuery.of(context).size.height / 3.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: upcomingTripsPostings.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(right: AppConstants.tinyPadding),
                        child: PostingGridTile(posting: upcomingTripsPostings[index].posting),
                        width: MediaQuery.of(context).size.width / 2.5,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewPostingPage()),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            HeadingText(text: 'Previous Trips'),
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.smallPadding, bottom: AppConstants.smallPadding),
              child: Container(
                height: MediaQuery.of(context).size.height / 3.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: previousTripsPostings.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(right: AppConstants.tinyPadding),
                        child: PostingGridTile(posting: previousTripsPostings[index].posting),
                        width: MediaQuery.of(context).size.width / 2.5,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewPostingPage()),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
