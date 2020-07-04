import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatefulWidget {
  final String url;

  FullScreenImage({this.url});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  bool showAppBar = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: showAppBar == true
          ? AppBar(
              backgroundColor: Color(0x44000000),
              elevation: 0,
              title: Text("Title"),
            )
          : null,
      body: GestureDetector(
        child: Center(
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            imageProvider: CachedNetworkImageProvider(
              widget.url,
            ),
          ),
        ),
        onTap: () {
          setState(() {
            showAppBar = !showAppBar;
          });
        },
      ),
    );
  }
}
