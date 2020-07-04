import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:places_app/screens/place_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  FirebaseUser user;
  String uid;

  String error;

  String postId;

  bool emptyFavorite;
  void setUser(FirebaseUser user) {
    setState(() {
      this.user = user;
      this.error = null;
    });
  }

  void setError(e) {
    setState(() {
      this.user = null;
      this.error = e.toString();
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  Future<void> deletePlace(String url, String id) async {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(url);
    await storageReference.delete();

    await Firestore.instance.collection('Places').document(id).delete();

    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Place deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  navigateToDetail(DocumentSnapshot place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailScreen(place),
      ),
    );
  }

  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: [
            Tab(
              text: 'My Places',
            ),
            Tab(
              text: 'Favorites',
            ),
          ],
          controller: _tabController,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              color: Colors.white,
              child: Text('LOG OUT'),
              onPressed: () => {
                _googleSignIn.signOut(),
                FirebaseAuth.instance.signOut(),
              },
            ),
          )
        ],
        title: Text('Profile'),
      ),
      body: TabBarView(
        children: <Widget>[
          FutureBuilder(
            future: FirebaseAuth.instance.currentUser(),
            builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                uid = snapshot.data.uid;

                return Column(children: <Widget>[
                  Expanded(
                    //height: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('Places')
                            .where('user_id', isEqualTo: snapshot.data.uid)
                            .snapshots(),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            if (snapshot.data.documents.length == 0) {
                              return Center(
                                child: Text('Nothing here yet'),
                              );
                            }
                            return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (_, index) {
                                  DocumentSnapshot myPlaces =
                                      snapshot.data.documents[index];

                                  return Card(
                                      child: ListTile(
                                    onTap: () {
                                      navigateToDetail(myPlaces);
                                    },
                                    trailing: IconButton(
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          content: Text(
                                              'Are you sure you want to delete the place'),
                                          actions: <Widget>[
                                            FlatButton(
                                                child: Text('Yes'),
                                                onPressed: () => setState(() {
                                                      deletePlace(
                                                          myPlaces['image'],
                                                          myPlaces['id']);
                                                      Navigator.pop(context);
                                                    })),
                                            FlatButton(
                                              child: Text('No'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            )
                                          ],
                                        ),
                                      ),
                                      icon: Icon(Icons.delete),
                                    ),
                                    leading: Image.network(myPlaces['image']),
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
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          FutureBuilder(
            future: FirebaseAuth.instance.currentUser(),
            builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                snapshot.data.uid;

                return Column(children: <Widget>[
                  Expanded(
                    //height: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('Places')
                            .where('likes', arrayContains: snapshot.data.uid)
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
                            if (snapshot.data.documents.length == 0) {
                              return Center(
                                child: Text('Nothing here yet'),
                              );
                            }
                            return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (_, index) {
                                  DocumentSnapshot myPlaces =
                                      snapshot.data.documents[index];

                                  return Card(
                                      child: ListTile(
                                    onTap: () {
                                      navigateToDetail(myPlaces);
                                    },
                                    trailing: IconButton(
                                      onPressed: () => {
                                        postId = snapshot
                                            .data.documents[index].data['id'],
                                        Firestore.instance
                                            .collection('Places')
                                            .document(postId)
                                            .updateData({
                                          'likes': FieldValue.arrayRemove([uid])
                                        }),
                                      },
                                      icon: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                    ),
                                    leading: Image.network(myPlaces['image']),
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
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
        controller: _tabController,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
