import 'package:flutter/material.dart';

import '../dimen/game_dimen.dart';
import '../util/util.dart';

enum BirdColor { red, blue, yellow }

enum FlightStage { down, mid, up }

class FlappyBird extends StatelessWidget {
  final BirdColor birdColor;
  final FlightStage flightStage;
  final double rotationDeg;
  static Rect rectBound =
      Rect.fromLTWH(0, 0, flappyBirdDimen['x']!, flappyBirdDimen['y']!);

  const FlappyBird({
    required this.birdColor,
    required this.flightStage,
    required this.rotationDeg,
    Key? key,
  }) : super(key: key);

  @override
  String toStringShort() => "My name is Dara";

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: toRadians(rotationDeg),
      child: Image.asset(
        "assets/images/${birdColor.name}bird-${flightStage.name}flap.png",
        fit: BoxFit.cover,
        height: flappyBirdDimen['y'],
        width: flappyBirdDimen['x'],
      ),
    );
  }
}
