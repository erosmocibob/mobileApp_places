import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:places_app/main.dart';
import 'package:places_app/screens/place_detail_screen.dart';

class UserPlaces extends StatefulWidget {
  final String id;
  final String username;

  const UserPlaces(this.id, this.username);
  @override
  _UserPlacesState createState() => _UserPlacesState();
}

class _UserPlacesState extends State<UserPlaces> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.home),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Home()),
              (Route<dynamic> route) => false),
        ),
        appBar: AppBar(),
        body: Column(children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'Places add by: ${widget.username}',
            style: TextStyle(fontSize: 14),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: Firestore.instance
                      .collection('Places')
                      .where("user_id", isEqualTo: widget.id)
                      .getDocuments(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Column(children: <Widget>[
                        Expanded(
                          //height: 400,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StreamBuilder(
                              stream: Firestore.instance
                                  .collection('Places')
                                  .where('user_id', isEqualTo: widget.id)
                                  .snapshots(),
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasData == null) {
                                  return Center(
                                    child: Text('test'),
                                  );
                                } else {
                                  return ListView.builder(
                                      itemCount: snapshot.data.documents.length,
                                      itemBuilder: (_, index) {
                                        DocumentSnapshot myPlaces =
                                            snapshot.data.documents[index];

                                        return Card(
                                            child: ListTile(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PlaceDetailScreen(myPlaces),
                                            ),
                                          ),
                                          leading:
                                              Image.network(myPlaces['image']),
                                          title: Text(
                                            myPlaces['adress']['city'],
                                          ),
                                          subtitle: Text(
                                            myPlaces['adress']['country'],
                                          ),
                                        ));
                                      });
                                }
                              },
                            ),
                          ),
                        ),
                      ]);
                    }
                  }),
            ),
          )
        ]));
  }
}
