import 'dart:io';

import 'package:airbnb/AppScreens/HomePage.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/OnDeviceDatabaseFunctions.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MySignUpPage extends StatefulWidget {

  final FirebaseAuth auth = FirebaseAuth.instance;

  MySignUpPage({Key key}) : super(key: key);

  @override
  _MySignUpPageState createState() => _MySignUpPageState();

}

class SignUpPage extends StatelessWidget {

  static final String routeName = "/signUpPage";

  @override
  Widget build(BuildContext context) {
    return MySignUpPage();
  }
}

class _MySignUpPageState extends State<MySignUpPage> {

  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  TextEditingController _locationController;
  TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  void _signUp() {
    if (_formKey.currentState.validate()) {
      _createFirebaseUser().then((firebaseUser) {
        AppConstants.currentUser.firstName = _firstNameController.text;
        AppConstants.currentUser.lastName = _lastNameController.text;
        AppConstants.currentUser.bio = _bioController.text;
        AppConstants.currentUser.location = _locationController.text;
        AppConstants.currentUser.id = firebaseUser.uid;

        UserLoginFunctions.saveUserInfo();

        widget.auth.signInWithEmailAndPassword(
            email: AppConstants.currentUser.email,
            password: AppConstants.currentUser.password).then((firebaseUser) {
          this._saveUserInfoToFirestore();
        });
      });
    }
  }

  Future<FirebaseUser> _createFirebaseUser() async {
    return await widget.auth.createUserWithEmailAndPassword(
        email: AppConstants.currentUser.email,
        password: AppConstants.currentUser.password);
  }

  void _saveUserInfoToFirestore() async {
    AppConstants.currentUser.addToFirestore().then((value) {
      File imageFile = File("assets/images/defaultAvatar.jpg");
      AppConstants.currentUser.saveImageToFirebase(imageFile).then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RegularText(text: "Sign Up Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.smallPadding,
          AppConstants.smallPadding,
          AppConstants.smallPadding,
          0.0,
        ),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                  child: HeadingText(text: "Saved Postings"),
                ),
                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "First name",
                            ),
                            controller: _firstNameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter your first name";
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Last name",
                            ),
                            controller: _lastNameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter your last name";
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Where are you located? (city, country)",
                            ),
                            controller: _locationController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter your location (city, country)";
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Tell us about yourself",
                            ),
                            maxLines: 3,
                            controller: _bioController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter some info about yourself";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 15.0,
                          child: MaterialButton(
                            onPressed: () => {
                              _signUp()
                            },
                            color: Colors.grey,
                            child: HeadingText(text: "Submit"),
                            height: MediaQuery.of(context).size.height / 15,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.regularCornerRadius),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
    );
  }
}
