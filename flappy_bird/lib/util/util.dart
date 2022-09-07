import 'dart:math';

import 'package:flutter/material.dart';

import '../dimen/game_dimen.dart';
import '../screen/flappy_bird_game.dart';
import 'custom_pipe_clipper.dart';

enum Direction { upToDown, downToUp }

extension DoubleUtil on double {
  double constrain(
    double lower,
    double upper,
  ) {
    if (upper < lower) {
      throw ArgumentError("Upper limit is greater than lower limit");
    }
    if (this > upper) {
      return upper;
    } else if (this < lower) {
      return lower;
    }
    return this;
  }

  double convertToAlignment(double screenWidth) {
    final middle = screenWidth / 2;
    var toReturn = 0.0;
    if (this == middle) toReturn = 0;
    if (this > middle) toReturn = (this - middle) / middle;
    if (this < middle) toReturn = -1 + (this / middle);
    return toReturn;
  }

  bool inRange(double lower, double upper) => lower <= this && this <= upper;
}

double toRadians(double degrees) {
  // if (degrees > 360|| degrees < 0) {
  //   throw UnsupportedError("invalid value for degrees: $degrees");
  // }
  return (degrees / 180) * pi;
}

extension ListUtil on List {
  List<K> mapIndexed<E, K>(K Function(int, E) action) {
    final toReturn = <K>[];
    for (int i = 0; i < length; i++) {
      toReturn.add(action(i, this[i]));
    }
    return toReturn;
  }
}

double abs(double num) => num > 0 ? num : num * -1;

class Pipes {
  final PipeColor pipeColor;
  final double topHeight =
      Random().nextInt(maxPipeHeight - minPipeHeight.toInt()).toDouble() +
          minPipeHeight;
  late double bottomHeight;

  Pipes(this.pipeColor);

  void initDimen() {
    bottomHeight = gameAreaHeight - pipeGapVertical - topHeight;
  }

  Widget drawPipe(BuildContext context) {
    // print("top:$topHeight   bottom:$bottomHeight, max:$maxPipeHeight");
    final uPipe = Transform.rotate(
        angle: pi,
        child: Transform.rotate(
          angle: pi,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationX(pi),
            child: ClipRect(
              clipper: PipeClipper(topHeight),
              child: Image.asset("assets/images/pipe-${pipeColor.name}.png"),
            ),
          ),
        ));
    final lPipe = ClipRect(
        clipper: PipeClipper(bottomHeight),
        child: Image.asset("assets/images/pipe-${pipeColor.name}.png"));
    return SizedBox(
      height: gameAreaHeight,
      width: pipeWidth,
      child: Stack(
        children: [
          Positioned(top: topHeight - pipeHeight, child: uPipe),
          Positioned(bottom: bottomHeight - pipeHeight, child: lPipe)
        ],
      ),
    );
  }
}
