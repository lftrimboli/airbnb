import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Reviews.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';

class ReviewForm extends StatefulWidget {

  final Function submitReview;

  ReviewForm({this.submitReview});

  @override
  _ReviewFormState createState() => _ReviewFormState();

}

class _ReviewFormState extends State<ReviewForm> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _reviewTextController = TextEditingController();
  double _rating = 2.5;

  void _submitReview() {
    if (_formKey.currentState.validate()) {
      Review review = Review();
      review.createReview(
          _rating,
          _reviewTextController.text, AppConstants.currentUser.createContactFromUser(),
          DateTime.now());
      widget.submitReview(review);
      setState(() {
        _reviewTextController.clear();
        _rating = 2.5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.tinyPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Enter review text"
                    ),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    controller: _reviewTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter some text first";
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.tinyPadding),
                    child: StarRating(
                      rating: _rating,
                      size: 40,
                      starCount: 5,
                      color: Colors.orange,
                      borderColor: Colors.grey,
                      onRatingChanged: (rating) {
                        setState(() {
                          this._rating = rating;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.tinyPadding),
              child: MaterialButton(
                child: Text("Submit"),
                onPressed: () {
                  _submitReview();
                },
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }

}
