import 'dart:async';

import 'package:airbnb/AppScreens/CreatePostingPage.dart';
import 'package:airbnb/AppScreens/HomePage.dart';
import 'package:airbnb/AppScreens/HostingHomePage.dart';
import 'package:airbnb/AppScreens/ListingsPage.dart';
import 'package:airbnb/AppScreens/LoginPage.dart';
import 'package:airbnb/AppScreens/SignUpPage.dart';
import 'package:airbnb/AppScreens/ViewPostingPage.dart';
import 'package:airbnb/AppScreens/ViewProfilePage.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/OnDeviceDatabaseFunctions.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'BookingPage.dart';
import 'ConversationPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
      routes: {
        HomePage.routeName: (context) => HomePage(),
        SignUpPage.routeName: (context) => SignUpPage(),
        LoginPage.routeName: (context) => LoginPage(),
        ViewProfilePage.routeName: (context) => ViewProfilePage(),
        ViewPostingPage.routeName: (context) => ViewPostingPage(),
        HostingHomePage.routeName: (context) => HostingHomePage(),
        CreatePostingPage.routeName: (context) => CreatePostingPage(),
        ListingsPage.routeName: (context) => ListingsPage(),
        ConversationPage.routeName: (context) => ConversationPage(),
        CalendarPage.routeName: (context) => CalendarPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {

  MainPage({Key key}) : super(key: key);

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  _MyMainPageState createState() => _MyMainPageState();

}

class _MyMainPageState extends State<MainPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _checkFirebaseUserCredentials(String email, String password, bool isCurrentlyHosting) async {
    AppConstants.currentUser = User();
    AppConstants.currentUser.email = email;
    AppConstants.currentUser.password = password;
    AppConstants.currentUser.isCurrentlyHosting = isCurrentlyHosting;
    await AppConstants.currentUser.getCurrentUserInfo(email, password);

    UserLoginFunctions.saveUserInfo();

    if (AppConstants.currentUser.isCurrentlyHosting) {
      Navigator.pushNamed(context, HostingHomePage.routeName);
    } else {
      Navigator.pushNamed(context, HomePage.routeName);
    }
  }

  @override
  void initState() {
    UserLoginFunctions.getUserInfo().then((user) {
      if (user != null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Loading user info..."), duration: Duration(seconds: 1),));
        _checkFirebaseUserCredentials(user.email, user.password, user.isCurrentlyHosting);
      } else {
        Timer(const Duration(seconds: 2), () {
          Navigator.pushNamed(context, LoginPage.routeName);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.smallPadding,
                  100,
                  AppConstants.smallPadding,
                  AppConstants.largePadding,
                ),
                child: HeadingText(
                  text: 'Welcome to ${AppConstants.appName}!',
                  fontSize: AppConstants.largeFontSize,
                ),
              ),
              Icon(
                Icons.hotel,
                size: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
