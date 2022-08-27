import 'package:flutter/material.dart';

import '../dimen/flappy_bird.dart';

enum BirdColor { red, blue, yellow }

enum FlightStage { down, mid, up }

class FlappyBird extends StatelessWidget {
  BirdColor birdColor;
  FlightStage flightStage;

  FlappyBird({
    required this.birdColor,
    required this.flightStage,
    Key? key,
  }) : super(key: key);

  @override
  String toStringShort() => "My name is Dara";

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/${birdColor.name}bird-${flightStage.name}flap.png",
      fit: BoxFit.contain,
      height: flappyBirdDimen[0],
      width: flappyBirdDimen[1],
    );
  }
}
