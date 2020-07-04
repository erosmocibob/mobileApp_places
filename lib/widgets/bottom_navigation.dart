import 'package:flutter/material.dart';
import 'package:places_app/screens/add_place_screen.dart';
import 'package:places_app/screens/places_screen.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  var _selectedPage = 0;
  final List<Widget> _pageOption = [
    PlacesScreen(),
    AddPlaceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOption[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 22,
        currentIndex: _selectedPage,
        onTap: (var index) {
          setState(() {
            _selectedPage = index;
          });
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
        ],
      ),
    );
  }
}
