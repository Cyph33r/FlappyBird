import 'package:flutter/material.dart';

import '../util/util.dart' show Direction;

class Pipe extends StatelessWidget {
  double gap;

  Pipe(this.gap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height = 150;
    const width = 80.0;
    Image top;
    Image bottom;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [],
    );
  }
}
