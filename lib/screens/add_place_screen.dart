import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:places_app/model/place.dart';
import 'package:places_app/widgets/location_input.dart';
import 'package:uuid/uuid.dart';
import '../helpers/location_helper.dart';
import 'package:path/path.dart' as path;

class AddPlaceScreen extends StatefulWidget {
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  File image;
  List<String> categoriesList = [
    "beach",
    "nature",
    "city",
    "historical",
    "other",
  ];

  static List<String> _choices = [
    "beach",
    "nature",
    "city",
    "historical",
    "other",
  ];
  int _defaultChoiceIndex;

  String selectedReportList;
  String selectedChip;

  File _selectedFile;

  PlaceLocation _pickedLocation;

  String selectedTag;

  void _selectPlace(double lat, double lng) {
    _pickedLocation = PlaceLocation(latitude: lat, longitude: lng);
  }

  bool loading = false;
  Map<String, dynamic> tags = {
    'beach': false,
    'city': false,
    'historical': false,
    'nature': false,
    'other': false,
  };

  void _addPlace() async {
    if (selectedTag == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Location categorie not choosen'),
        ),
      );
    } else if (_selectedFile == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Image not added'),
        ),
      );
    } else if (_pickedLocation == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing location'),
        ),
      );
    } else {
      setState(() {
        loading = true;
      });
      try {
        Map<String, String> adressTest = await LocationHelper.getAdress(
            _pickedLocation.latitude, _pickedLocation.longitude);

        var fileExtension = path.extension(_selectedFile.path);
        var uuid = Uuid().v4();
        final StorageReference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('places/images/$uuid$fileExtension');

        firebaseStorageRef
            .putFile(_selectedFile)
            .onComplete
            .catchError((onError) {
          print(onError);
        });

        StorageUploadTask uploadTask =
            firebaseStorageRef.putFile(_selectedFile);
        print(uploadTask);
        var downURl = await (await uploadTask.onComplete).ref.getDownloadURL();
        var url = downURl.toString();

        var firebaserUser = await FirebaseAuth.instance.currentUser();

        tags.update(selectedTag, (value) => true);
        print(url);
        DocumentReference documentReference =
            await Firestore.instance.collection('Places').add(
          {
            'id': Uuid().v4(),
            'user_id': firebaserUser.uid,
            'image': url,
            'adress': {
              'city': adressTest['city'],
              'country': adressTest['country']
            },
            'tags': tags,
            'coordinates':
                GeoPoint(_pickedLocation.latitude, _pickedLocation.longitude),
            'likes': [],
          },
        );
        await documentReference.setData({
          'id': documentReference.documentID,
        }, merge: true);

        tags.update(selectedTag, (value) => false);
        setState(() {
          loading = false;
          _selectedFile = image;
        });
      } catch (err) {
        print(err);
      }

      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Place successfully added'),
        ),
      );
    }
  }

  Widget getImageWidget() {
    if (_selectedFile != null) {
      return Image.file(_selectedFile,
          width: double.infinity, height: 250, fit: BoxFit.scaleDown);
    } else {
      return Image.asset(
        "assets/images/picture_placeholder.png",
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );
    }
  }

  getImage(ImageSource source) async {
    this.setState(() {});
    image = await ImagePicker.pickImage(
      source: source,
      imageQuality: 70,
      maxHeight: 768,
      maxWidth: 1024,
    );

    if (image != null) {
      this.setState(() {
        _selectedFile = image;
      });
    }
  }

  Widget placeCategories() {
    return Column(
      children: <Widget>[
        Text(
          'Choose place category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget choiceChips() {
    return Container(
      child: Wrap(
        spacing: 3.0,
        runSpacing: 4.0,
        children: List<Widget>.generate(
          _choices.length,
          (index) {
            return ChoiceChip(
              label: Text(_choices[index]),
              selected: _defaultChoiceIndex == index,
              onSelected: (bool selected) {
                setState(() {
                  _defaultChoiceIndex = selected ? index : null;
                  selectedTag = _choices[_defaultChoiceIndex];
                });
              },
            );
          },
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a New Place'),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          getImageWidget(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                MaterialButton(
                                  child: Text('Camera'),
                                  onPressed: () => getImage(ImageSource.camera),
                                  color: Colors.green,
                                ),
                                MaterialButton(
                                  child: Text(' Device'),
                                  onPressed: () =>
                                      getImage(ImageSource.gallery),
                                  color: Colors.red,
                                ),
                              ]),
                          SizedBox(
                            height: 10,
                          ),
                          LocationInput(_selectPlace),
                          SizedBox(height: 15),
                          const Divider(
                            color: Colors.grey,
                            height: 10,
                            thickness: 2,
                            indent: 0,
                            endIndent: 0,
                          ),
                          SizedBox(height: 15),
                          placeCategories(),
                          choiceChips(),
                          RaisedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Add Place'),
                            onPressed: _addPlace,
                            elevation: 0,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            color: Theme.of(context).accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
