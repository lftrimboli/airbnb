import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/AppScreens/ExplorePage.dart';
import 'package:airbnb/AppScreens/InboxPage.dart';
import 'package:airbnb/AppScreens/PersonalProfilePage.dart';
import 'package:airbnb/AppScreens/SavedPage.dart';
import 'package:airbnb/AppScreens/TripsPage.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class HomePage extends StatelessWidget {

  static final String routeName = "/homePageRoute";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: AppConstants.appName);
  }
}

class _MyHomePageState extends State<MyHomePage> {

  int currentIndex = 4;

  final List<Widget> tabPages = [
    ExplorePage(),
    SavedPage(),
    TripsPage(),
    InboxPage(),
    ProfileSettingsPage(),
  ];

  final List<String> pageTitles = [
    "Explore",
    "Saved",
    "Trips",
    "Inbox",
    "Profile",
  ];

  void selectNewTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  BottomNavigationBarItem _buildBottomNavItem(int index, IconData iconData, String text) {
    return BottomNavigationBarItem(
      icon: Icon(
        iconData,
        color: Colors.black,
      ),
      activeIcon: Icon(
        iconData,
        color: Colors.deepOrange,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: currentIndex == index ? Colors.deepOrange : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(pageTitles[currentIndex]),
      ),
      body: tabPages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: selectNewTab,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        items: <BottomNavigationBarItem>[
          _buildBottomNavItem(0, Icons.search, "Explore"),
          _buildBottomNavItem(1, Icons.favorite_border, "Saved"),
          _buildBottomNavItem(2, Icons.hotel, "Trips"),
          _buildBottomNavItem(3, Icons.message, "Inbox"),
          _buildBottomNavItem(4, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }
}