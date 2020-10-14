import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:flutter/material.dart';

class PostingGridTile extends StatefulWidget {

  final Posting posting;

  PostingGridTile({Key key, this.posting}): super(key: key);

  @override
  State<PostingGridTile> createState() => _PostingGridTileState();

}

class _PostingGridTileState extends State<PostingGridTile> {

  MemoryImage displayImage;

  @override
  void initState() {
    widget.posting.loadFirstImageFromDatabase().then((image) {
      setState(() {
        displayImage = image;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 3/2,
          child: (displayImage == null ) ? Container() : Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: displayImage,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        HeadingText(text: widget.posting.type + " - " + widget.posting.location, fontSize: AppConstants.tinyFontSize,),
        HeadingText(text: widget.posting.name, fontSize: AppConstants.smallFontSize,),
        Text("\$${widget.posting.price} / night"),
        HeadingText(text: "${widget.posting.rating}/5 stars", fontSize: AppConstants.tinyFontSize,),
      ],
    );
  }

}