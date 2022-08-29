import 'package:flutter/cupertino.dart';

class PipeClipper extends CustomClipper<Rect> {
  final double clipLength;

  const PipeClipper(this.clipLength);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, clipLength);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
