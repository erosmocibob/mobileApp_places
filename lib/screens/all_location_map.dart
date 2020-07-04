import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:url_launcher/url_launcher.dart';

class AllLocationMap extends StatefulWidget {
  @override
  _AllLocationMapState createState() => _AllLocationMapState();
}

class _AllLocationMapState extends State<AllLocationMap> {
  final PopupController _popupController = PopupController();
  List<Marker> allMarkers = [];
  var latLangToLabel = {};
  int pointIndex;
  List points = [
    LatLng(51.5, -0.09),
    LatLng(49.8566, 3.3522),
  ];

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

  void addMarkers() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('Places').getDocuments();

    for (int i = 0; i < snapshot.documents.length; i++) {
      var latLangValue = LatLng(snapshot.documents[i]['coordinates'].latitude,
          snapshot.documents[i]['coordinates'].longitude);

      allMarkers.add(
        Marker(
          anchorPos: AnchorPos.align(AnchorAlign.center),
          height: 30,
          width: 30,
          point: latLangValue,
          builder: (ctx) => Icon(Icons.pin_drop),
        ),
      );

      latLangToLabel[latLangValue] = {
        "id": snapshot.documents[i].data['id'],
        "city": snapshot.documents[i].data['adress']["city"],
        "country": snapshot.documents[i].data['adress']["country"],
        "image": snapshot.documents[i].data['image'],
      };
    }

    setState(() {
      allMarkers = [...allMarkers];
    });
  }

  @override
  void initState() {
    addMarkers();
    pointIndex = 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: points[0],
          zoom: 5,
          plugins: [
            MarkerClusterPlugin(),
          ],
          onTap: (_) => _popupController.hidePopup(),
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerClusterLayerOptions(
            maxClusterRadius: 120,
            size: Size(40, 40),
            anchor: AnchorPos.align(AnchorAlign.center),
            fitBoundsOptions: FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            markers: allMarkers,
            polygonOptions: PolygonOptions(
                borderColor: Colors.blueAccent,
                color: Colors.black12,
                borderStrokeWidth: 3),
            popupOptions: PopupOptions(
                popupSnap: PopupSnap.top,
                popupController: _popupController,
                popupBuilder: (_, marker) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        width: 220,
                        height: 120,
                        color: Colors.white,
                        child: GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content:
                                  Text('Get directions by opening Google maps'),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text('Yes'),
                                    onPressed: () => setState(() {
                                          double lat = marker.point.latitude;
                                          double long = marker.point.longitude;

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
                          child: GridTile(
                            child: Image.network(
                              latLangToLabel[marker.point]['image'],
                              fit: BoxFit.fill,
                            ),
                            footer: Container(
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      '  ${latLangToLabel[marker.point]['city']}, ${latLangToLabel[marker.point]['country']}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    Icon(
                                      Icons.directions,
                                      color: Colors.yellow,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
            builder: (context, markers) {
              return FloatingActionButton(
                backgroundColor: Colors.blue[300],
                child: Text(markers.length.toString()),
                onPressed: null,
              );
            },
          ),
        ],
      ),
    );
  }
}
