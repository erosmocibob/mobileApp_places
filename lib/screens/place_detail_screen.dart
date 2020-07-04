import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:places_app/model/place.dart';
import 'package:places_app/screens/map_screen.dart';
import 'package:places_app/screens/user_places.dart';
import 'package:places_app/widgets/full_screen_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatefulWidget {
  final DocumentSnapshot place;

  PlaceDetailScreen(this.place);

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Can not open Google maps'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  String userName;
  @override
  Widget build(BuildContext context) {
    var a = widget.place.data["coordinates"].latitude;
    var b = widget.place.data['coordinates'].longitude;
    PlaceLocation location = PlaceLocation(
        latitude: widget.place.data['coordinates'].latitude,
        longitude: widget.place.data['coordinates'].longitude);
    String userId = widget.place.data['user_id'];

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Image.network(
                  widget.place.data['image'],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return FullScreenImage(url: widget.place.data['image']);
                  }));
                },
              ),
              Ink(
                color: Colors.grey[200],
                child: InkWell(
                  splashColor: Colors.yellow,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserPlaces(
                            userId,
                            userName,
                          ))),
                  child: Container(
                    height: 40,
                    //    color: Colors.grey[200],
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.person_outline),
                        Text(
                          ' Location add by: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        FutureBuilder(
                          future: Firestore.instance
                              .collection('Users')
                              .document(widget.place.data['user_id'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Loading...');
                            } else {
                              userName = snapshot.data['username'];
                              return Text(snapshot.data['username'],
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ));
                              // return Container(
                              //   margin: EdgeInsets.all(4),
                              //   padding: EdgeInsets.all(6),
                              //   alignment: Alignment.center,
                              //   decoration: BoxDecoration(
                              //     color: Colors.white,
                              //     border: Border.all(
                              //         color:
                              //             Colors.blue[900], // set border color
                              //         width: 2.0), // set border width
                              //     borderRadius: BorderRadius.all(
                              //         Radius.circular(
                              //             10.0)), // set rounded corner radius
                              //   ),
                              //   child: Text(snapshot.data['username']),
                              // );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Text(
                widget.place.data['adress']['city'],
                style: TextStyle(fontSize: 20),
              ),
              Text(
                widget.place.data['adress']['country'],
                style: TextStyle(fontSize: 12),
              ),
              Text('$a'),
              Text(',$b'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Text(
                            'Are you sure you want to open Google map on your phone'),
                        actions: <Widget>[
                          FlatButton(
                              child: Text('Yes'),
                              onPressed: () => setState(() {
                                    double lat = widget
                                        .place.data['coordinates'].latitude;
                                    double long = widget
                                        .place.data['coordinates'].longitude;

                                    String url =
                                        'https://www.google.com/maps/dir/?api=1&destination=$lat,$long';
                                    _launchURL(url);
                                    Navigator.pop(context);
                                  })),
                          FlatButton(
                            child: Text('No'),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    ),
                    child: Text('Get directions'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MapScreen(initialLocation: location),
                        ),
                      );
                    },
                    child: Text('Show on map'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
