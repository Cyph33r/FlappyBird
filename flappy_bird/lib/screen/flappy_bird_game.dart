// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flappy_bird/constants/constants.dart';
import 'package:flappy_bird/util/util.dart';
import 'package:flappy_bird/widgets/flappy_bird.dart';
import 'package:flappy_bird/widgets/pipe.dart';
import 'package:flutter/material.dart';

import '../dimen/game_dimen.dart';
import '../util/debug_container.dart';

enum GameState { welcome, playing, ended }

enum PipeColor { green, red }

enum BackgroundState { day, night }

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({Key? key}) : super(key: key);

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame> {
  AudioPlayer wingPlayer = AudioPlayer();
  AudioPlayer diePlayer = AudioPlayer();
  AudioPlayer hitPlayer = AudioPlayer();
  AudioPlayer pointPlayer = AudioPlayer();

  var gameState = GameState.welcome; //todo:change this back
  var backgroundState = BackgroundState.values[Random().nextInt(2)];
  var pipeColor = PipeColor.values[Random().nextInt(2)];
  var isUpdating = false;
  var baseShiftX = 0.0;

  @override
  void dispose() {
    wingPlayer.dispose();
    super.dispose();
  }

  var playerScore = 0;
  var pipes = <Pipes>[];
  final pipeLocation = <Map<String, double>>[];
  final flappybirdState = {
    flappyBirdX: flappyBirdStartingPos['x'],
    flappyBirdY: flappyBirdStartingPos['y'],
    flappyBirdRotationDeg: 0.0,
    flappyBirdColor: BirdColor.red,
    flappyBirdFlightStage: FlightStage.mid,
    flappyBirdIsJumping: false,
    flappyBirdDir: 1,
    heightToJump: 0,
  };
  var dt = 3; //FPSCLOCK.tick(FPS) / 1000
  var pipeVelX = -128; //* dt;

  // player velocity, max velocity, downward acceleration, acceleration on flap
  var playerVelY =
      -9; // player's velocity along Y, default same as playerFlapped
  var playerMaxVelY = 10; // max vel along Y, max descend speed
  var playerMinVelY = -8; // min vel along Y, max ascend speed
  var playerAccY = 1; // players downward acceleration
  var playerRot = 45; // player's rotation
  var playerVelRot = 3; // angular speed
  var playerRotThr = 20; // rotation threshold
  var playerFlapAcc = -9; // players speed on flapping
  // var playerFlapped = false; True when player flaps

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
  final audioAssets = [
    "assets/audio/wing.wav",
    "assets/audio/die.wav",
    "assets/audio/hit.wav",
    "assets/audio/point.wav",
    "assets/audio/swoosh.wav"
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
    checkCollision();
    updateBird();
    isUpdating = false;
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (TapDownDetails details) => handleTap(1),
          onTapUp: (TapUpDetails details) => handleTap(0),
          child: Center(
            child: Container(
              width: min(width, screenDimen['x']!),
              height: min(height, screenDimen['y']!),
              color: const Color(0x00000000),
              child: Stack(
                children: [
                  //get new background
                  Positioned(top: 0, left: 0, child: drawBackgroundTop()),

                  Positioned(
                      left: baseShiftX, bottom: 0, child: drawBackgroundBase()),
                  //todo: get new pipes
                  if (true)
                    ...(pipes.mapIndexed((int index, Pipes item) => Positioned(
                          left: pipeLocation[index]['x']!,
                          top: 0,
                          child: item.drawPipe(context),
                        ))),
                  //todo: get new bird
                  Positioned(
                    left: flappybirdState[flappyBirdX] as double,
                    top: flappybirdState[flappyBirdY] as double,
                    child: DebugContainer(
                      child: FlappyBird(
                          birdColor:
                              flappybirdState[flappyBirdColor]! as BirdColor,
                          flightStage: flappybirdState[flappyBirdFlightStage]
                              as FlightStage,
                          rotationDeg:
                              flappybirdState[flappyBirdRotationDeg] as double),
                    ),
                  ),
                  //todo: if game over, show the game over banner
                  //get new score
                  if (gameState == GameState.playing ||
                      gameState == GameState.ended)
                    Padding(
                      padding: const EdgeInsets.only(top: 64),
                      child: drawScores(),
                    ),
                  Positioned(
                    top: pipes.length > 1
                        ? gameAreaHeight - pipes[1].bottomHeight
                        : 0,
                    child: Container(
                      height: 1,
                      width: screenDimen['x'],
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple)),
                    ),
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

  void handleTap(int upDown) {
    switch (gameState) {
      case GameState.welcome:
        gameState = GameState.playing;
        break;
      case GameState.playing:
        flappybirdState[flappyBirdIsJumping] = true;
        if (wingPlayer.state == PlayerState.playing) {
          wingPlayer.stop();
        }

        flappybirdState[flappyBirdDir] = upDown == 0 ? 1 : -1;
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
    if (gameState == GameState.welcome || gameState == GameState.playing) {
      baseShiftX = -((-baseShiftX + 4) % baseXOffset);
    }
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
      pipes.last.initDimen();
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
        if (abs((flappybirdState[flappyBirdY] as double) -
                (flappyBirdStartingPos['y'] as double)) ==
            10.0) {
          flappybirdState[flappyBirdDir] =
              (flappybirdState[flappyBirdDir] as int) * -1;
        }
        if (flappybirdState[flappyBirdDir] == -1) {
          flappybirdState[flappyBirdY] =
              (flappybirdState[flappyBirdY] as double) - 1;
        }
        if (flappybirdState[flappyBirdDir] == 1) {
          flappybirdState[flappyBirdY] =
              (flappybirdState[flappyBirdY] as double) + 1;
        }
        break;
      case GameState.playing:


        break;
      case GameState.ended:
        // TODO: Handle this case.
        break;
    }
  }

  void checkCollision() {
    if (gameState == GameState.playing) {
      // get the bird bounds
      final flappyBirdTop = flappybirdState[flappyBirdY] as double;
      final flappyBirdLeft = flappybirdState[flappyBirdX] as double;
      final flappyBirdRight = flappyBirdLeft + (flappyBirdDimen['x'] as double);
      final flappyBirdBottom = flappyBirdTop + (flappyBirdDimen['y'] as double);

      var isColliding = false;
      for (int i = 0; i < pipes.length; i++) {
        final upperPipeY = pipes[i].topHeight;
        final lowerPipeY = gameAreaHeight - pipes[i].bottomHeight;
        final pipesX = pipeLocation[i]['x'] as double;
        print(flappybirdState);
        //check floor collision
        if (flappyBirdBottom >= gameAreaHeight) {
          print("floor");
          print("$flappyBirdBottom ${baseDimen['y']!}");
          isColliding = true;
        }
        //check pipe collision
        if (flappyBirdRight.inRange(pipesX, pipesX + pipeWidth)) {
          //check top collision
          if (flappyBirdTop.inRange(0, upperPipeY)) {
            print("upperPipeY:$upperPipeY");
            print("top");
            isColliding = true;
          }
          //check bottom collision
          if (flappyBirdBottom.inRange(lowerPipeY, gameAreaHeight)) {
            print("bottom");
            print("lowerPipeY:$lowerPipeY  $gameAreaHeight");
            isColliding = true;
          }
        }
      }

      if (isColliding) wingPlayer.play(AssetSource("audio/swoosh.wav"));
    }
  }

  void onGameOver() {}
}
