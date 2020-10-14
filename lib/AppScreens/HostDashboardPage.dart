import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:flutter/material.dart';

class MyHostDashboardPage extends StatefulWidget {

  MyHostDashboardPage({Key key}) : super(key: key);

  @override
  _MyHostDashboardPageState createState() => _MyHostDashboardPageState();

}

class HostDashboardPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MyHostDashboardPage();
  }
}

class _MyHostDashboardPageState extends State<MyHostDashboardPage> {

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
          HeadingText(text: "Progress Page"),
        ],
      ),
    );
  }
}
