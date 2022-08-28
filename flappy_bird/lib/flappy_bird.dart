// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:flappy_bird/util/util.dart';
import 'package:flappy_bird/widgets/flappy_bird.dart';
import 'package:flutter/material.dart';

import 'dimen/flappy_bird.dart';

enum GameState { welcome, playing, ended }

enum BackgroundState { day, night }

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({Key? key}) : super(key: key);

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame> {
  var gameState = GameState.welcome;
  var backgroundState = BackgroundState.day;
  var isUpdating = false;
  var baseShiftX = 0.0;

  var playerScore = 0;
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
    isUpdating = false;
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: handleTap,
          child: Center(
            child: DebugContainer(
              child: Container(
                width: min(width, screenDimen['x']!),
                height: min(height, screenDimen['y']!),
                color: const Color(0x00000000),
                child: Stack(
                  children: [
                    //todo: get new background
                    drawBackgroundTop(),
                    Positioned(
                        left: baseShiftX,
                        bottom: 0,
                        child: drawBackgroundBase()),
                    //todo: get new score
                    if (gameState == GameState.playing)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: drawScores(),
                      ),
                    //todo: get new pipes
                    //todo: get new bird
                    //todo: if game over, show the game over banner
                    // if welcome show welcome banner
                    if (gameState == GameState.welcome) drawWelcome(),
                  ],
                ),
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
        playerScore++;
        break;
      case GameState.ended:
        // TODO: Handle this case.
        break;
    }
  }

  Widget drawWelcome() {
    return Center(
      child: Image.asset("assets/images/message.png"),
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

  Widget drawBackgroundTop() {
    return Image.asset(
      "assets/images/background-${backgroundState.name}.png",
      height: screenDimen['y']!,
      width: screenDimen['x']!,
      fit: BoxFit.contain,
    );
  }

  Widget drawBackgroundBase() {
    if (gameState == GameState.playing) baseShiftX = -((-baseShiftX + 4) % 30);
    return Image.asset(
      "assets/images/base.png",
      height: 140,
      width: screenDimen['x']! + 30,
      fit: BoxFit.cover,
      // repeat: ImageRepeat.repeatX,
    );
  }

  void drawBird() {}

  void drawPipe() {}

  bool checkCollision() {
    return false;
  }

  void onWelcome() {}

  void onPlaying() {}

  void onGameOver() {}
}
