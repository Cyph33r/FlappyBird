import 'dart:math';

import 'package:flutter/material.dart';

import '../dimen/game_dimen.dart';
import '../screen/flappy_bird_game.dart';
import '../util/custom_pipe_clipper.dart';

class Pipes extends StatelessWidget {
  final PipeColor pipeColor;
  final double topRatio = Random().nextDouble();

  Pipes(this.pipeColor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topHeight = max(minPipeHeight,topRatio  * maxPipeHeight);
    final bottomHeight = (gameAreaHeight - pipeGapVertical) - topHeight;
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
          Positioned(top: -(pipeHeight - topHeight), child: uPipe),
          Positioned(
              bottom: -(pipeGapVertical + (pipeHeight - bottomHeight)),
              child: lPipe)
        ],
      ),
    );
  }
}
