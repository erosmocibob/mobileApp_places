import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
            color: Colors.red,
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
