import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:places_app/screens/add_place_screen.dart';
import 'package:places_app/screens/all_location_map.dart';
import 'package:places_app/screens/login_screen.dart';
import 'package:places_app/screens/places_screen.dart';
import 'package:places_app/screens/profile_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              return Home();
            }
            return LoginScreen();
          }),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _screenList = [
    PlacesScreen(),
    AddPlaceScreen(),
    AllLocationMap(),
    ProfileScreen()
  ];

  int _tabSelected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenList[_tabSelected],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.blue[100],
        currentIndex: _tabSelected,
        onTap: (int index) {
          _tabSelected = index;
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.view_quilt),
              title: Text('Feed'),
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              title: Text('Add'),
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              title: Text('Map'),
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
              backgroundColor: Colors.blue),
        ],
      ),
    );
  }
}
