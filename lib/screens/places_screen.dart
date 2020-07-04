import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:places_app/screens/place_detail_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/place.dart';

class PlacesScreen extends StatefulWidget {
  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  FirebaseUser user;
  String uid;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  static List<String> _choices = [
    "all",
    "beach",
    "nature",
    "city",
    "historical",
  ];
  int _defaultChoiceIndex = 0;

  @override
  void initState() {
    getCurrentUser();

    super.initState();
  }

  Future getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      } else {}
      setState(() {});
    } catch (e) {}
  }

  String tag = '';

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
              autofocus: true,
              selected: _defaultChoiceIndex == index,
              onSelected: (bool selected) {
                setState(() {
                  _defaultChoiceIndex = selected ? index : null;

                  tag = _choices[_defaultChoiceIndex];
                });
              },
            );
          },
        ).toList(),
      ),
    );
  }

  Future<void> getPlaces() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('Places').getDocuments();

    List<Place> _placesList = [];

    snapshot.documents.forEach((document) {
      Place place = Place.fromMap(document.data);
      _placesList.add(place);
    });
  }

  Future getTags(String a) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('Places')
        .where("tags.$a", isEqualTo: true)
        .getDocuments();

    return snapshot.documents;
  }

  Stream<dynamic> getTagsStream(String a) {
    Stream snapshot = Firestore.instance
        .collection('Places')
        .where("tags.$a", isEqualTo: true)
        .snapshots();

    return snapshot;
  }

  Future getPlacesFuture() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('Places').getDocuments();

    return snapshot.documents;
  }

  navigateToDetail(DocumentSnapshot place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailScreen(place),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              uid = snapshot.data.uid;
              return Column(
                children: <Widget>[
                  choiceChips(),
                  Divider(
                    height: 10,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: _defaultChoiceIndex == 0
                          ? Firestore.instance.collection('Places').snapshots()
                          : getTagsStream(tag),
                      builder: (_, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return GridView.builder(
                            itemCount: snapshot.data.documents.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 14.0,
                              crossAxisCount: 2,
                            ),
                            itemBuilder: (_, index) {
                              DocumentSnapshot places =
                                  snapshot.data.documents[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(9.0),
                                child: GridTile(
                                  child: GestureDetector(
                                    onTap: () => navigateToDetail(places),
                                    child: Image.network(
                                      places['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  header: Align(
                                    alignment: Alignment.topRight,
                                    child: LikeButton(uid, places, index),
                                  ),
                                  footer: Container(
                                      padding:
                                          EdgeInsets.only(left: 8, bottom: 5),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.bottomRight,
                                              colors: [
                                            Colors.black.withOpacity(.8),
                                            Colors.black.withOpacity((.2))
                                          ])),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: <Widget>[
                                            Text(places['adress']['city'],
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            Text(places['adress']['country'],
                                                style: TextStyle(
                                                    color: Colors.blue[400])),
                                          ],
                                        ),
                                      )),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  )),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class LikeButton extends StatefulWidget {
  final String user;
  final DocumentSnapshot snapshot;
  final int number;
  LikeButton(
    this.user,
    this.snapshot,
    this.number,
  );
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

bool liked = false;

checkLike<bool>(DocumentSnapshot snapshot, int index, String user) {
  return (snapshot['likes']).contains(user);
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            color: Colors.yellow,
            icon: Icon(checkLike(widget.snapshot, widget.number, widget.user)
                ? Icons.favorite
                : Icons.favorite_border),
            onPressed: () {
              if ((widget.snapshot['likes']).contains(widget.user)) {
                var a = Firestore.instance
                    .collection('Places')
                    .document(widget.snapshot['id']);
                Firestore.instance
                    .collection('Places')
                    .document(a.documentID)
                    .updateData({
                  'likes': FieldValue.arrayRemove([widget.user])
                });
              } else {
                var b = Firestore.instance
                    .collection('Places')
                    .document(widget.snapshot['id']);

                Firestore.instance
                    .collection('Places')
                    .document(b.documentID)
                    .updateData({
                  'likes': FieldValue.arrayUnion([widget.user])
                });
              }

              setState(() {
                liked = !liked;
              });
            }),
      ],
    );
  }
}
