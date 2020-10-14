import 'package:airbnb/AppScreens/BookingPage.dart';
import 'package:airbnb/AppScreens/HostDashboardPage.dart';
import 'package:airbnb/AppScreens/InboxPage.dart';
import 'package:airbnb/AppScreens/ListingsPage.dart';
import 'package:airbnb/AppScreens/PersonalProfilePage.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:flutter/material.dart';

class MyHostingHomePage extends StatefulWidget {

  MyHostingHomePage({Key key}) : super(key: key);

  @override
  _MyHostingHomePageState createState() => _MyHostingHomePageState();

}

class HostingHomePage extends StatelessWidget {

  static final String routeName = "/hostingHomePageRoute";

  @override
  Widget build(BuildContext context) {
    return MyHostingHomePage();
  }
}

class _MyHostingHomePageState extends State<MyHostingHomePage> {

  int currentIndex = 3;

  final List<Widget> tabPages = [
    CalendarPage(),
    ListingsPage(),
    InboxPage(),
    ProfileSettingsPage(),
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
    final int argumentIndex = ModalRoute.of(context).settings.arguments;
    if (argumentIndex != null) {
      currentIndex = argumentIndex;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RegularText(text: 'Hosting Home Page'),
      ),
      body: tabPages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: selectNewTab,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        items: <BottomNavigationBarItem>[
          _buildBottomNavItem(0, Icons.calendar_today, "Calendar"),
          _buildBottomNavItem(1, Icons.home, "Listings"),
          _buildBottomNavItem(2, Icons.message, "Inbox"),
          _buildBottomNavItem(3, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }
}
