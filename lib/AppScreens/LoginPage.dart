import 'package:airbnb/AppScreens/HomePage.dart';
import 'package:airbnb/AppScreens/HostingHomePage.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/OnDeviceDatabaseFunctions.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyLoginPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyLoginPage();
  }
}

class LoginPage extends StatefulWidget {

  final FirebaseAuth auth = FirebaseAuth.instance;
  static final String routeName = 'loginPageRoute';

  LoginPage({Key key}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();

}

class _MyLoginPageState extends State<LoginPage> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState.validate()) {
      _checkFirebaseUserCredentials(_emailController.text, _passwordController.text, false);
    }
  }

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

  void _signUp() {
    if (_formKey.currentState.validate()) {
      AppConstants.currentUser = User();
      AppConstants.currentUser.email = _emailController.text;
      AppConstants.currentUser.password = _passwordController.text;
      Navigator.pushNamed(context, '/signUpRoute');
    }
  }

  void _forgotPassword() {
    // TODO Implement password forgot
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Not implemented yet")));
  }

  @override
  void initState() {
    UserLoginFunctions.getUserInfo().then((user) {
      if (user != null) {
        _checkFirebaseUserCredentials(user.email, user.password, user.isCurrentlyHosting);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  AppConstants.largePadding,
                  AppConstants.smallPadding,
                  AppConstants.smallPadding,
                ),
                child: Text(
                  'Welcome to ${AppConstants.appName}!',
                  style: TextStyle(
                    fontSize: AppConstants.largeFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.smallPadding,
                        AppConstants.smallPadding,
                        AppConstants.smallPadding,
                        AppConstants.tinyPadding,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "Email"),
                        style: TextStyle(
                          fontSize: AppConstants.regularFontSize,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (value) {
                          if (value.isEmpty || !value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "Password"),
                        style: TextStyle(
                          fontSize: AppConstants.regularFontSize,
                        ),
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty || value.length < 6) {
                            return "Enter a valid password (6 or more characters)";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.smallPadding,
                  AppConstants.smallPadding,
                  AppConstants.smallPadding,
                  0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 12.0,
                  child: MaterialButton(
                    onPressed: () => {
                      _login()
                    },
                    child: HeadingText(text: "Login"),
                    color: Colors.blue,
                    height: MediaQuery.of(context).size.height / 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.regularCornerRadius),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.smallPadding,
                  AppConstants.smallPadding,
                  AppConstants.smallPadding,
                  0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 12.0,
                  child: MaterialButton(
                    onPressed: () => {
                      _signUp()
                    },
                    color: Colors.grey,
                    child: HeadingText(text: "Sign up"),
                    height: MediaQuery.of(context).size.height / 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.regularCornerRadius),
                    ),
                  ),
                ),
              ),
              MaterialButton(
                onPressed: _forgotPassword,
                child: RegularText(
                  text: "Forgot your password?",
                  fontSize: AppConstants.smallFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
