import 'package:airbnb/AppScreens/HostingHomePage.dart';
import 'package:airbnb/AppScreens/ListingsPage.dart';
import 'package:airbnb/CustomWidgets/TextViews.dart';
import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyCreatePostingPage extends StatefulWidget {

  MyCreatePostingPage({Key key}) : super(key: key);

  @override
  _MyCreatePostingPageState createState() => _MyCreatePostingPageState();

}

class CreatePostingPage extends StatelessWidget {

  static String routeName = '/createPostingPage';

  @override
  Widget build(BuildContext context) {
    return MyCreatePostingPage();
  }
}

class _MyCreatePostingPageState extends State<MyCreatePostingPage> {

  GlobalKey _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _priceController;
  TextEditingController _descriptionController;
  TextEditingController _addressController;
  TextEditingController _locationController;
  TextEditingController _amenitiesController;

  Posting _posting;
  bool hasSetUpPosting = false;

  String _pageTitle;
  String _name;
  String _priceString;
  String _description;
  String _address;
  String _location;
  String _type;
  Map<String, int> _bedrooms;
  Map<String, int> _bathrooms;
  String _amenitiesString;
  List<MemoryImage> _images;

  void _savePosting() {
    print("posting id is ${_posting.id}");
    _posting.name = _nameController.text;
    _posting.type = _type;
    _posting.price = double.parse(_priceController.text);
    _posting.description = _descriptionController.text;
    _posting.address = _addressController.text;
    _posting.location = _locationController.text;
    _posting.bedroomTypes = _bedrooms;
    _posting.bathroomTypes = _bathrooms;
    _posting.amenities = _amenitiesController.text.split(", ");
    _posting.postingImages = _images;

    _posting.savePostingToFirestore().then((id) {
      _posting.id = id;
      _posting.saveImages().whenComplete(() {
        AppConstants.currentUser.addPostingToSaved(_posting);

        Navigator.pushNamed(
          context,
          HostingHomePage.routeName,
          arguments: 1,
        );
      });
    });
  }

  void _selectNewImage(int index) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) { return; }
    if (index == -1) {
      setState(() {
        _images.add(MemoryImage(image.readAsBytesSync()));
      });
    } else {
      setState(() {
        _images[index] = MemoryImage(image.readAsBytesSync());
      });
    }
  }

  void _changeNumberOfBedrooms(String type, int byAmount) {
    setState(() {
      _bedrooms[type] += byAmount;
      if (_bedrooms[type] < 0) { _bedrooms[type] = 0; }
    });
  }

  void _changeNumberOfBathrooms(String type, int byAmount) {
    setState(() {
      _bathrooms[type] += byAmount;
      if (_bathrooms[type] < 0) { _bathrooms[type] = 0; }
    });
  }

  void _setUpDefaultValues() {
    _pageTitle = "Create a Posting";
    _name = "";
    _priceString = "";
    _description = "";
    _address = "";
    _location = "";
    _bedrooms = {
      "small": 0,
      "medium": 0,
      "large": 0,
    };
    _bathrooms = {
      "half": 0,
      "full": 0,
    };
    _amenitiesString = "";
    _images = [];

    _setUpControllers();
  }

  void _setUpInitialValues() {
    this._pageTitle = "Edit posting";
    this._name = _posting.name;
    this._type = _posting.type;
    this._priceString = _posting.price.toString();
    this._description = _posting.description;
    this._address = _posting.address;
    this._location = _posting.location;
    this._bedrooms = _posting.bedroomTypes;
    this._bathrooms = _posting.bathroomTypes;
    this._amenitiesString = _posting.getAmenitiesString();
    hasSetUpPosting = true;
    _posting.loadImagesFromDatabase().then((images) {
      setState(() {
        _images = images;
      });
    });
    _setUpControllers();
  }

  void _setUpControllers() {
    _nameController = TextEditingController(text: _name);
    _priceController = TextEditingController(text: _priceString);
    _descriptionController = TextEditingController(text: _description);
    _addressController = TextEditingController(text: _address);
    _locationController = TextEditingController(text: _location);
    _amenitiesController = TextEditingController(text: _amenitiesString);
  }

  @override
  void initState() {
    _setUpDefaultValues();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Posting passedPosting = ModalRoute.of(context).settings.arguments;
    if (passedPosting != null) {
      if (!hasSetUpPosting) {
        this._posting = passedPosting;
        _setUpInitialValues();
      }
    } else {
      this._posting = Posting();
    }

    return Scaffold(
      appBar: AppBar(
        title: RegularText(text: "Posting"),
        actions: <Widget>[
          MaterialButton(
            child: RegularText(text: "Save"),
            textColor: Colors.white,
            onPressed: () {
              _savePosting();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.smallPadding,
            AppConstants.smallPadding,
            AppConstants.smallPadding,
            0.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                child: HeadingText(text: _pageTitle),
              ),
              Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5.0),
                          labelText: "Name"
                        ),
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize,
                        ),
                        controller: _nameController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a name";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, AppConstants.tinyPadding, 0.0, AppConstants.smallPadding),
                      child: DropdownButton(
                        isExpanded: true,
                        value: _type,
                        hint: RegularText(text: "Select home type:"),
                        items: <String>["House", "Apartment", "1 Bedroom", "Townhouse"].map((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: RegularText(text: value)
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _type = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(5.0),
                                  labelText: "Price"
                              ),
                              style: TextStyle(
                                fontSize: AppConstants.smallFontSize,
                              ),
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter a price";
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: AppConstants.tinyPadding, left: AppConstants.smallPadding),
                            child: RegularText(text: "\$/night"),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5.0),
                            labelText: "Description",
                        ),
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize,
                        ),
                        controller: _descriptionController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a description";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5.0),
                          labelText: "Address"
                        ),
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize,
                        ),
                        maxLines: 2,
                        controller: _addressController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter an address";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5.0),
                            labelText: "City, Country"
                        ),
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize,
                        ),
                        maxLines: 2,
                        controller: _locationController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter city, country";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        5.0,
                        AppConstants.tinyPadding,
                        0.0,
                        AppConstants.tinyPadding
                      ),
                      child: RegularText(text: "Beds"),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppConstants.smallPadding,
                        0.0,
                        AppConstants.smallPadding,
                        AppConstants.smallPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: RegularText(text: "Twin/Single")),
                              Padding(
                                padding: const EdgeInsets.only(left: AppConstants.smallPadding, right: AppConstants.smallPadding),
                                child: RegularText(text: _bedrooms["small"].toString()),
                              ),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      _changeNumberOfBedrooms("small", -1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _changeNumberOfBedrooms("small", 1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: RegularText(text: "Double")),
                              Padding(
                                padding: const EdgeInsets.only(left: AppConstants.smallPadding, right: AppConstants.smallPadding),
                                child: RegularText(text: _bedrooms["medium"].toString()),
                              ),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      _changeNumberOfBedrooms("medium", -1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _changeNumberOfBedrooms("medium", 1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: RegularText(text: "Queen/King")),
                              Padding(
                                padding: const EdgeInsets.only(left: AppConstants.smallPadding, right: AppConstants.smallPadding),
                                child: RegularText(text: _bedrooms["large"].toString()),
                              ),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      _changeNumberOfBedrooms("large", -1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _changeNumberOfBedrooms("large", 1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        5.0,
                        AppConstants.tinyPadding,
                        0.0,
                        AppConstants.tinyPadding),
                      child: RegularText(text: "Bathrooms"),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppConstants.smallPadding,
                        0.0,
                        AppConstants.smallPadding,
                        AppConstants.smallPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: RegularText(text: "Full")),
                              Padding(
                                padding: const EdgeInsets.only(left: AppConstants.smallPadding, right: AppConstants.smallPadding),
                                child: RegularText(text: _bathrooms["full"].toString()),
                              ),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      _changeNumberOfBathrooms("full", -1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _changeNumberOfBathrooms("full", 1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: RegularText(text: "Half")),
                              Padding(
                                padding: const EdgeInsets.only(left: AppConstants.smallPadding, right: AppConstants.smallPadding),
                                child: RegularText(text: _bathrooms["half"].toString()),
                              ),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      _changeNumberOfBathrooms("half", -1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _changeNumberOfBathrooms("half", 1);
                                    },
                                    iconSize: 15.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                      child: TextField(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5.0),
                            labelText: "Amenities (separated by commas)"
                        ),
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize,
                        ),
                        controller: _amenitiesController,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: AppConstants.mediumPadding),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: _images.length + 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppConstants.smallPadding,
                    crossAxisSpacing: AppConstants.smallPadding,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return (index == _images.length)
                    ? Padding(
                      padding: EdgeInsets.all(15.0),
                      child: MaterialButton(
                        child: Icon(Icons.add),
                        onPressed: () {
                          _selectNewImage(-1);
                        },
                        color: Colors.grey,
                      ),
                    )
                    : MaterialButton(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 0),
                              image: DecorationImage(
                                image: _images[index],
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          _selectNewImage(index);
                        },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


