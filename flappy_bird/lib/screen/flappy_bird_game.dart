// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';

import 'package:flappy_bird/util/util.dart';
import 'package:flappy_bird/widgets/flappy_bird.dart';
import 'package:flappy_bird/widgets/pipe.dart';
import 'package:flutter/material.dart';

import '../dimen/game_dimen.dart';

enum GameState { welcome, playing, ended }

enum PipeColor { green, red }

enum BackgroundState { day, night }

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({Key? key}) : super(key: key);

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame> {
  var gameState = GameState.welcome; //todo:change this back
  var backgroundState = BackgroundState.values[Random().nextInt(2)];
  var pipeColor = PipeColor.values[Random().nextInt(2)];
  var isUpdating = false;
  var baseShiftX = 0.0;

  var playerScore = 0;
  var pipes = <Pipes>[];
  final pipeLocation = <Map<String, double>>[];
  final birdState = {
    'x': screenDimen['x']! * .2,
    'y': gameAreaHeight / 2,
    'rotation_deg': 0.0,
    'color': BirdColor.red,
    'flight_stage': FlightStage.mid,
    'isJumping': false,
  };
  static const scoreAssets = [
    "assets/images/0.png",
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
    "assets/images/4.png",
    "assets/images/5.png",
    "assets/images/6.png",
    "assets/images/7.png",
    "assets/images/8.png",
    "assets/images/9.png"
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 33), (timer) {
      //should be 33
      if (!isUpdating) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    isUpdating = true;
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.vertical;
    final width = MediaQuery.of(context).size.width;
    if (gameState == GameState.playing) updatePipe();
    isUpdating = false;
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: handleTap,
          child: Center(
            child: Container(
              width: min(width, screenDimen['x']!),
              height: min(height, screenDimen['y']!),
              color: const Color(0x00000000),
              child: Stack(
                children: [
                  //get new background
                  Positioned(top: 0, left: 0, child: drawBackgroundTop()),
                  if (gameState == GameState.welcome ||
                      gameState == GameState.playing)
                    Positioned(
                        left: baseShiftX,
                        bottom: 0,
                        child: drawBackgroundBase()),
                  //todo: get new pipes
                  if (true)
                    ...(pipes.mapIndexed((int index, Pipes item) => Positioned(
                          left: pipeLocation[index]['x']!,
                          child: item,
                        ))),
                  //todo: get new bird
                  Positioned(
                    left: birdState['x'] as double,
                    top: birdState['y'] as double,
                    child: FlappyBird(
                        birdColor: birdState['color']! as BirdColor,
                        flightStage: birdState['flight_stage'] as FlightStage,
                        rotationDeg: birdState['rotation_deg'] as double),
                  ),
                  //todo: if game over, show the game over banner
                  //get new score
                  if (gameState == GameState.playing)
                    Padding(
                      padding: const EdgeInsets.only(top: 64),
                      child: drawScores(),
                    ),
                  // if welcome show welcome banner
                  if (gameState == GameState.welcome)
                    Positioned(
                        right: width / 2 - welcomeMessageDimen['x']! / 2,
                        top: gameAreaHeight * .1,
                        child: drawWelcome()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleTap() {
    switch (gameState) {
      case GameState.welcome:
        gameState = GameState.playing;
        break;
      case GameState.playing:
        birdState['isJumping'] = true;
        break;
      case GameState.ended:
        return;
    }
  }

  Widget drawWelcome() {
    return Image.asset(
      "assets/images/message.png",
      width: welcomeMessageDimen['x']!,
      height: welcomeMessageDimen['y']!,
      fit: BoxFit.cover,
    );
  }

  Widget drawScores() {
    final scoreToString = playerScore.toString();
    final digitImage = <Widget>[];
    for (String digit in scoreToString.split("")) {
      digitImage.add(Image.asset(scoreAssets[int.parse(digit)]));
      digitImage.add(const SizedBox(
        width: 4,
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: digitImage,
    );
  }

  Widget drawBackgroundTop() => Image.asset(
        "assets/images/background-${backgroundState.name}.png",
        width: backgroundDimen['x']!,
        height: backgroundDimen['y'],
        fit: BoxFit.contain,
      );

  Widget drawBackgroundBase() {
    baseShiftX = -((-baseShiftX + 4) % baseXOffset);
    return Image.asset(
      "assets/images/base.png",
      height: baseDimen['y'],
      width: baseDimen['x']! + baseXOffset,
      fit: BoxFit.cover,
      // repeat: ImageRepeat.repeatX,
    );
  }

  void updatePipe() {
    if (pipes.isEmpty || pipeLocation.last['x']! <= screenDimen['x']!) {
      pipes.add(Pipes(pipeColor));
      pipeLocation.add({'x': screenDimen['x']! + pipeGapHorizontal, 'y': 0.0});
    }
    for (var location in pipeLocation) {
      location['x'] = location['x']! - 4;
    }
    pipeLocation.removeWhere(
        (Map<String, double> location) => location['x']! < -pipeWidth);
    pipes.removeRange(0, pipes.length - pipeLocation.length);
  }

  void updateBird() {
    switch (gameState) {
      case GameState.welcome:
        // TODO: Handle this case.
        break;
      case GameState.playing:
        // TODO: Handle this case.
        break;
      case GameState.ended:
        // TODO: Handle this case.
        break;
    }
  }

  bool checkCollision() {
    return false;
  }

  void onWelcome() {}

  void onPlaying() {}

  void onGameOver() {}
}
