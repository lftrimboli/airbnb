import 'package:airbnb/Models/AppConstants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {

  final String text;
  final double fontSize;

  HeadingText({this.text, this.fontSize=AppConstants.regularFontSize, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      this.text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

}

class RegularText extends StatelessWidget {

  final String text;
  final double fontSize;

  RegularText({this.text, this.fontSize=AppConstants.smallFontSize, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      this.text,
      style: TextStyle(
        fontSize: fontSize,
      ),
    );
  }

}

//class RegularTextInput extends StatelessWidget {
//
//  final String hintText;
//  final double fontSize;
//
//  RegularTextInput({this.hintText, this.fontSize=AppConstants.regularFontSize, Key key}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return TextField(
//      decoration: InputDecoration(
//          hintText: this.hintText,
//      ),
//      style: TextStyle(
//        fontSize: this.fontSize,
//      ),
//    );
//  }
//
//}