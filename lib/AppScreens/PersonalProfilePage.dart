import 'package:airbnb/AppScreens/HomePage.dart';
import 'package:airbnb/AppScreens/HostDashboardPage.dart';
import 'package:airbnb/AppScreens/HostingHomePage.dart';
import 'package:airbnb/AppScreens/LoginPage.dart';
import 'package:airbnb/AppScreens/main.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/AppScreens/PersonalInformationPage.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/AppScreens/ViewProfilePage.dart';
import 'package:airbnb/Models/OnDeviceDatabaseFunctions.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfileSettingsPage extends StatefulWidget {

  MyProfileSettingsPage({Key key, this.title}) : super(key: key);

  final String title;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  _MyProfileSettingsPageState createState() => _MyProfileSettingsPageState();

}

class ProfileSettingsPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyProfileSettingsPage(title: AppConstants.appName);
  }
}

class _MyProfileSettingsPageState extends State<MyProfileSettingsPage> {

  String _hostingString;
  MemoryImage _profileImage;

  void _navigateToProfilePage() {
    Navigator.pushNamed(
      context,
      ViewProfilePage.routeName,
      arguments: AppConstants.currentUser.createContactFromUser(),
    );
  }

  void _navigateToSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonalInformationPage()),
    );
  }

  void _changeCurrentlyHosting() {
    if (AppConstants.currentUser.isHost) {
      if (AppConstants.currentUser.isCurrentlyHosting) {
        AppConstants.currentUser.changeHosting(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        AppConstants.currentUser.changeHosting(true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HostingHomePage()),
        );
      }
    } else {
      AppConstants.currentUser.becomeAHost();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HostingHomePage()),
      );
    }
  }

  void _navigateToLoginPage() {
    widget.auth.signOut();
    AppConstants.currentUser = null;
    UserLoginFunctions.clearUserInfo();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _loadImage() {
    AppConstants.currentUser.getImageFromDatabase().then((image){
      setState(() {
        _profileImage = image;
      });
    });
  }

  void _setHostingString() {
    _hostingString = AppConstants.currentUser.isHost ? "Hosting Dashboard": "Become a Host";
    if (AppConstants.currentUser.isCurrentlyHosting) {
      _hostingString = "Guest Home";
    }
  }

  @override
  void initState() {
    _setHostingString();
    _loadImage();

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
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, AppConstants.smallPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: _navigateToProfilePage,
                  child: CircleAvatar(
                    backgroundImage: _profileImage,
                    radius: MediaQuery.of(context).size.width / 10.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppConstants.smallPadding, 0.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HeadingText(
                        text: AppConstants.currentUser.firstName,
                        fontSize: AppConstants.largeFontSize,
                      ),
                      RegularText(
                        text: AppConstants.currentUser.email,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  child: PersonalProfilePageListTile(
                    text: "Personal Information",
                    iconData: Icons.person,
                  ),
                  onTap: () {
                    _navigateToSettingsPage();
                  },
                ),
                PersonalProfilePageListTile(
                  text: "Payment Options",
                  iconData: Icons.payment,
                ),
                PersonalProfilePageListTile(
                  text: "Notifications",
                  iconData: Icons.notifications,
                ),
                GestureDetector(
                  child: PersonalProfilePageListTile(
                    text: _hostingString,
                    iconData: Icons.hotel,
                  ),
                  onTap: _changeCurrentlyHosting,
                ),
                GestureDetector(
                  child: PersonalProfilePageListTile(
                    text: "Log Out",
                    iconData: null,
                  ),
                  onTap: _navigateToLoginPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalProfilePageListTile extends StatelessWidget {

  final String text;
  final IconData iconData;

  PersonalProfilePageListTile({Key key, this.text, this.iconData}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.tinyPadding),
      child: ListTile(
        leading: RegularText(text: text),
        trailing: Icon(iconData, size: 30.0,),
      ),
    );
  }

}