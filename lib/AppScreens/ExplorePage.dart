import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/CustomWidgets/GridTiles.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:airbnb/AppScreens/ViewPostingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyExplorePage extends StatefulWidget {

  MyExplorePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyExplorePageState createState() => _MyExplorePageState();

}

class ExplorePage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyExplorePage(title: AppConstants.appName);
  }
}

class _MyExplorePageState extends State<MyExplorePage> {

  List<Posting> postings = [];

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
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, AppConstants.mediumPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                contentPadding: EdgeInsets.all(5.0),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ),
          StreamBuilder(
            stream: Firestore.instance.collection('homes').snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Center(child: new CircularProgressIndicator());
                default:
                  return Expanded(
                    child: GridView.builder(
                      itemCount: snapshot.data.documents.length,
                      shrinkWrap: false,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConstants.tinyPadding,
                        mainAxisSpacing: AppConstants.smallPadding,
                        childAspectRatio: 3/4,
                      ),
                      itemBuilder: (context, index) {
                        Posting posting = Posting();
                        posting.getInfoFromDatabase(snapshot.data.documents[index]);
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ViewPostingPage.routeName,
                              arguments: posting,
                            );
                          },
                          child: PostingGridTile(posting: posting),
                        );
                      },
                    ),
                  );
              }
            }
          ),
        ],
      ),
    );
  }
}

