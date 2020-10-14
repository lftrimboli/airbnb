import 'package:airbnb/AppScreens/ViewPostingPage.dart';
import 'package:airbnb/CustomWidgets/GridTiles.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:flutter/material.dart';

class MySavedPage extends StatefulWidget {

  MySavedPage({Key key}) : super(key: key);

  @override
  _MySavedPageState createState() => _MySavedPageState();

}

class SavedPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MySavedPage();
  }
}

class _MySavedPageState extends State<MySavedPage> {

  @override
  void initState() {

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
            child: HeadingText(text: "Saved Postings"),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: AppConstants.currentUser.savedTrips.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.tinyPadding,
                mainAxisSpacing: AppConstants.smallPadding,
                childAspectRatio: 3/4,
              ),
              itemBuilder: (context, index) {
                Posting posting = AppConstants.currentUser.savedTrips[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ViewPostingPage.routeName,
                      arguments: posting,
                      );
                  },
                  onLongPress: () {
                    AppConstants.currentUser.removePostingFromSaved(posting);
                    setState(() {

                    });
                  },
                  child: PostingGridTile(posting: posting),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
