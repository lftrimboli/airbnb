import 'package:airbnb/Models/Users.dart';
import 'package:flutter/material.dart';

class AppConstants {

  static const String AndroidAPIKey = "AIzaSyD7fDd1gKzRReOu8q_unDymCBIhD6BkLMI";
  static const String appName = 'Hotel Buddy';

  static const double tinyFontSize = 15.0;
  static const double smallFontSize = 20.0;
  static const double regularFontSize = 25.0;
  static const double largeFontSize = 35.0;

  static const double regularCornerRadius = 10.0;

  static const double tinyPadding = 10.0;
  static const double smallPadding = 25.0;
  static const double mediumPadding = 50.0;
  static const double largePadding = 75.0;

  static Color messageYellow = Color.fromARGB(255, 245, 215, 66);
  static Color messageBlue = Color.fromARGB(255, 66, 173, 245);

  static User currentUser;

  static Map<String, String> months = {
    "01": "January",
    "02": "February",
    "03": "March",
    "04": "April",
    "05": "May",
    "06": "June",
    "07": "July",
    "08": "August",
    "09": "September",
    "10": "October",
    "11": "November",
    "12": "December",
  };

  static Map<int, int> daysInMonths = {
    1: 31,
    2: (DateTime.now().year % 4 == 0) ? 29 : 28,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31
  };

}