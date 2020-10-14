import 'dart:io';
import 'package:airbnb/AppScreens/HomePage.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyPersonalInformationPage extends StatefulWidget {

  MyPersonalInformationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyPersonalInformationPageState createState() => _MyPersonalInformationPageState();

}

class PersonalInformationPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyPersonalInformationPage(title: AppConstants.appName);
  }
}

class _MyPersonalInformationPageState extends State<MyPersonalInformationPage> {

  Map<String, String> userInfo;
  List<TextEditingController> textControllers;

  bool _imageChanged = false;
  File _newImage;

  void saveInfo() {
    AppConstants.currentUser.firstName = userInfo['First Name'];
    AppConstants.currentUser.lastName = userInfo['Last Name'];
    AppConstants.currentUser.bio = userInfo['Bio'];
    AppConstants.currentUser.location = userInfo['Location'];

    AppConstants.currentUser.saveToFirestore().then((value) {
      AppConstants.currentUser.saveImageToFirebase(_newImage).whenComplete(() {
        print("Going to the next page");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    });
  }
  void _openImageSelector() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageChanged = true;
        _newImage = image;
      });
    }
  }

  @override
  void initState() {
    setState(() {
      userInfo = {
        "First Name": AppConstants.currentUser.firstName,
        "Last Name": AppConstants.currentUser.lastName,
        "Bio": AppConstants.currentUser.bio,
        "Location": AppConstants.currentUser.location,
      };
      textControllers = List<TextEditingController>();
      userInfo.forEach((key, value) {
        textControllers.add(TextEditingController(text: value));
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        actions: <Widget>[
          MaterialButton(
            onPressed: saveInfo,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: AppConstants.smallFontSize,
                color: Colors.white,
              ),
            ),
            textColor: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.smallPadding,
          AppConstants.smallPadding,
          AppConstants.smallPadding,
          0.0,
        ),
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: userInfo.keys.length,
              itemBuilder: (context, index) {
                final String key = userInfo.keys.toList()[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                  child: TextField(
                    controller: textControllers[index],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(5.0),
                      labelText: key,
                    ),
                    style: TextStyle(
                      fontSize: AppConstants.smallFontSize,
                    ),
                    maxLines: (key == "Bio") ? 3 : 1,
                    onChanged: (text) {
                      setState(() {
                        userInfo[key] = text;
                      });
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.smallPadding),
              child: RawMaterialButton(
                onPressed: _openImageSelector,
                child: CircleAvatar(
                  backgroundImage: (_imageChanged == false)
                      ? AppConstants.currentUser.displayImage
                      : FileImage(_newImage),
                  radius: MediaQuery.of(context).size.width / 5.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
