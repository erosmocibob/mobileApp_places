import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:places_app/model/place.dart';

class MapScreen extends StatefulWidget {
  final PlaceLocation initialLocation;
  final bool isSelecting;

  MapScreen(
      {this.initialLocation = const PlaceLocation(
          latitude: 42.815010799999996, longitude: 15.9819189),
      this.isSelecting = false});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        actions: <Widget>[
          if (widget.isSelecting)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          zoom: 6,
          minZoom: 4,
          center: LatLng(widget.initialLocation.latitude,
              widget.initialLocation.longitude),
          onTap: widget.isSelecting ? _selectLocation : null,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/code666/ck9s9g1zl5qth1ilcpz53i0wz/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY29kZTY2NiIsImEiOiJjazlxcWp4aG4wbXZpM2ZydGN2Y3lreWp4In0.QiGCfEaYOmkIFvRU7ApP0Q',
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoiY29kZTY2NiIsImEiOiJjazlxcWp4aG4wbXZpM2ZydGN2Y3lreWp4In0.QiGCfEaYOmkIFvRU7ApP0Q',
              'id': 'mapbox://styles/code666/ck9s9g1zl5qth1ilcpz53i0wz',
            },
          ),
          MarkerLayerOptions(
            markers: (_pickedLocation == null && widget.isSelecting)
                ? []
                : [
                    new Marker(
                      width: 45.0,
                      height: 45.0,
                      point: _pickedLocation ??
                          LatLng(widget.initialLocation.latitude,
                              widget.initialLocation.longitude),
                      builder: (context) => new Container(
                        child: IconButton(
                          icon: Icon(Icons.location_on),
                          color: Colors.red,
                          iconSize: 45.0,
                          onPressed: () {
                            print('Marker tapped');
                          },
                        ),
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}
