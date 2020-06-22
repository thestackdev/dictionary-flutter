import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final imageUrl;

  const FullScreenImageView({Key key, this.imageUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Related Image',
          style: TextStyle(
              letterSpacing: 1.0, fontSize: 21, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Image.network(
            imageUrl,
          ),
        ),
      ),
    );
  }
}
