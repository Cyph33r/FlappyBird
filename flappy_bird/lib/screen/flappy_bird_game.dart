// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flappy_bird/constants/constants.dart';
import 'package:flappy_bird/util/util.dart';
import 'package:flappy_bird/widgets/flappy_bird.dart';
import 'package:flutter/material.dart';

import '../dimen/game_dimen.dart';

enum GameState { welcome, playing, ending, ended }

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

  Future<void> playWing() {
    if (wingPlayer.state == PlayerState.playing) wingPlayer.stop();
    return wingPlayer.play(AssetSource('audio/wing.wav'));
  }

  Future<void> playDie() {
    if (diePlayer.state == PlayerState.playing) diePlayer.stop();
    return diePlayer.play(AssetSource('audio/die.wav'));
  }

  Future<void> playHit() {
    if (hitPlayer.state == PlayerState.playing) hitPlayer.stop();
    return hitPlayer.play(AssetSource('audio/hit.wav'));
  }

  Future<void> playPoint() {
    if (pointPlayer.state == PlayerState.playing) pointPlayer.stop();
    return pointPlayer.play(AssetSource('audio/point.wav'));
  }

  var gameState = GameState.welcome;
  var backgroundState = BackgroundState.values[Random().nextInt(2)];
  var pipeColor = PipeColor.values[Random().nextInt(2)];
  var isUpdating = false;
  var baseShiftX = 0.0;

  double visibleRotation = 0;

  @override
  void dispose() {
    wingPlayer.dispose();
    diePlayer.dispose();
    hitPlayer.dispose();
    pointPlayer.dispose();
    super.dispose();
  }

  var playerScore = 0;
  var pipes = <Pipes>[];
  final pipeLocation = <Map<String, double>>[];
  final wingLocations = [0, 1, 2, 1];
  var wingPosIndex = 1;
  var flappyBirdState = {
    flappyBirdX: flappyBirdStartingPos['x']!,
    flappyBirdY: flappyBirdStartingPos['y']!,
    flappyBirdRotationDeg: 0.0,
    flappyBirdColor: BirdColor.values[Random().nextInt(3)],
    flappyBirdFlightStage: FlightStage.mid,
    flappyBirdIsJumping: false,
    flappyBirdDir: 1,
    heightToJump: 0,
    flappyBirdIsFalling: false,
  };

  // player velocity, max velocity, downward acceleration, acceleration on flap
  var playerVelY =
      -9; // player's velocity along Y, default same as playerFlapped
  var playerMaxVelY = 10; // max vel along Y, max descend speed
  var playerMinVelY = -8; // min vel along Y, max ascend speed
  var playerAccY = 1; // players downward acceleration
  // var playerRot = 45; // player's rotation
  var playerVelRot = 1.2; // angular speed
  var playerRotThr = -20.0; // rotation threshold
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
    if (gameState == GameState.playing) {
      updatePipe();
      checkCollision();
    }
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
                    left: flappyBirdState[flappyBirdX] as double,
                    top: flappyBirdState[flappyBirdY] as double,
                    child: FlappyBird(
                        birdColor:
                            flappyBirdState[flappyBirdColor]! as BirdColor,
                        flightStage: flappyBirdState[flappyBirdFlightStage]
                            as FlightStage,
                        rotationDeg: visibleRotation),
                  ),
                  //todo: if game over, show the game over banner
                  //get new score
                  if (gameState == GameState.playing ||
                      gameState == GameState.ended)
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

  void handleTap(int upDown) {
    switch (gameState) {
      case GameState.welcome:
        gameState = GameState.playing;
        break;
      case GameState.playing:
        if (upDown == 1) {
          flappyBirdState[flappyBirdIsJumping] = true;
          playWing();
        }
        break;
      case GameState.ended:
        resetGame();
        return;
      case GameState.ending:
        break;
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
    if (pipeLocation.isNotEmpty &&
        (flappyBirdState[flappyBirdX] as double).inRange(
            pipeLocation[0]['x']! + pipeWidth,
            pipeLocation[0]['x']! + 4 + pipeWidth)) {
      playPoint();
      playerScore++;
    }

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
    if (gameState == GameState.welcome || gameState == GameState.playing) {
      wingPosIndex = wingPosIndex == 3 ? 0 : wingPosIndex + 1;
      flappyBirdState[flappyBirdFlightStage] =
          FlightStage.values[wingLocations[wingPosIndex]];
    }
    switch (gameState) {
      case GameState.welcome:
        if (abs((flappyBirdState[flappyBirdY] as double) -
                (flappyBirdStartingPos['y'] as double)) ==
            10.0) {
          flappyBirdState[flappyBirdDir] =
              (flappyBirdState[flappyBirdDir] as int) * -1;
        }
        if (flappyBirdState[flappyBirdDir] == -1) {
          flappyBirdState[flappyBirdY] =
              (flappyBirdState[flappyBirdY] as double) - 1;
        }
        if (flappyBirdState[flappyBirdDir] == 1) {
          flappyBirdState[flappyBirdY] =
              (flappyBirdState[flappyBirdY] as double) + 1;
        }
        break;
      case GameState.playing: //update the rotation angle
        //check if the player flapped
        if (flappyBirdState[flappyBirdIsJumping] as bool) {
          flappyBirdState[flappyBirdRotationDeg] = -45.0;
          playerVelY = playerFlapAcc;
          flappyBirdState[flappyBirdIsJumping] = true;
        }
        //update rotation
        flappyBirdState[flappyBirdRotationDeg] =
            (flappyBirdState[flappyBirdRotationDeg] as double) + playerVelRot;
        if ((flappyBirdState[flappyBirdRotationDeg] as double) >= 90) {
          flappyBirdState[flappyBirdRotationDeg] = 90.0;
        }
        visibleRotation = playerRotThr.toDouble();
        if ((flappyBirdState[flappyBirdRotationDeg] as double) >=
            playerRotThr) {
          visibleRotation = flappyBirdState[flappyBirdRotationDeg] as double;
        }
        flappyBirdState[flappyBirdRotationDeg] =
            (flappyBirdState[flappyBirdRotationDeg] as double) + playerVelRot;
        //update the height
        if (playerVelY < playerMaxVelY &&
            !(flappyBirdState[flappyBirdIsJumping] as bool)) {
          playerVelY += playerAccY;
        }
        if ((flappyBirdState[flappyBirdIsJumping] as bool)) {
          flappyBirdState[flappyBirdIsJumping] = false;
        }
        flappyBirdState[flappyBirdY] = min(
            gameAreaHeight - flappyBirdDimen['y']!,
            (flappyBirdState[flappyBirdY] as double) + playerVelY.toDouble());

        break;
      case GameState.ending:
        //update rotation
        flappyBirdState[flappyBirdRotationDeg] =
            (flappyBirdState[flappyBirdRotationDeg] as double) + playerVelRot;
        if ((flappyBirdState[flappyBirdRotationDeg] as double) >= 90) {
          flappyBirdState[flappyBirdRotationDeg] = 90.0;
        }
        visibleRotation = playerRotThr.toDouble();
        if ((flappyBirdState[flappyBirdRotationDeg] as double) >=
            playerRotThr) {
          visibleRotation = flappyBirdState[flappyBirdRotationDeg] as double;
        }
        flappyBirdState[flappyBirdRotationDeg] =
            (flappyBirdState[flappyBirdRotationDeg] as double) +
                playerVelRot +
                1.8; //rotate faster when falling
        //update height
        if ((flappyBirdState[flappyBirdIsFalling] as bool) &&
            (flappyBirdState[flappyBirdY] as double) + 15 <=
                gameAreaHeight - flappyBirdDimen['y']!) {
          flappyBirdState[flappyBirdY] =
              (flappyBirdState[flappyBirdY] as double) +
                  20; //play ending animation
        } else {
          gameState = GameState.ended;
        }
        break;
      case GameState.ended:
        break;
    }
  }

  void checkCollision() async {
    if (gameState == GameState.playing) {
      // get the bird bounds
      final flappyBirdTop = flappyBirdState[flappyBirdY] as double;
      final flappyBirdLeft = flappyBirdState[flappyBirdX] as double;
      final flappyBirdRight = flappyBirdLeft + (flappyBirdDimen['x'] as double);
      final flappyBirdBottom = flappyBirdTop + (flappyBirdDimen['y'] as double);
      var isColliding = false;
      //check floor collision
      if (flappyBirdBottom >= gameAreaHeight) {
        // print("$flappyBirdBottom ${baseDimen['y']!}");
        print('floor');
        flappyBirdState[flappyBirdIsFalling] = false;
        isColliding = true;
      }
      for (int i = 0; i < pipes.length && !isColliding; i++) {
        //break the loop if colliding
        final upperPipeY = pipes[i].topHeight;
        final lowerPipeY = gameAreaHeight - pipes[i].bottomHeight;
        final pipesX = pipeLocation[i]['x'] as double;
        //check right collision
        if (flappyBirdRight.inRange(pipesX, pipesX + 4) &&
            (flappyBirdBottom.inRange(
                    lowerPipeY, gameAreaHeight + flappyBirdDimen['y']!) ||
                flappyBirdTop <= upperPipeY)) {
          flappyBirdState[flappyBirdIsFalling] = true;
          isColliding = true;
          break;
        }
        //check pipe collision
        if (flappyBirdRight.inRange(
            pipesX, pipesX + pipeWidth + flappyBirdDimen['x']!)) {
          //check top collision
          if (flappyBirdTop <= upperPipeY) {
            flappyBirdState[flappyBirdIsFalling] = false;
            isColliding = true;
            break;
          }
          //check bottom collision
          if (flappyBirdBottom >= lowerPipeY) {
            flappyBirdState[flappyBirdIsFalling] = false;
            isColliding = true;
            break;
          }
        }
      }

      if (isColliding) {
        gameState = GameState.ending;
        await playHit();
        if (flappyBirdState[flappyBirdIsFalling] as bool) playDie();
      }
    }
  }

  void resetGame() {
    gameState = GameState.playing;
    backgroundState = BackgroundState.values[Random().nextInt(2)];
    pipeColor = PipeColor.values[Random().nextInt(2)];
    isUpdating = false;
    baseShiftX = 0.0;

    visibleRotation = 0;
    playerScore = 0;
    pipes.clear();
    pipeLocation.clear();
    wingPosIndex = 1;
    flappyBirdState = {
      flappyBirdX: flappyBirdStartingPos['x']!,
      flappyBirdY: flappyBirdStartingPos['y']!,
      flappyBirdRotationDeg: 0.0,
      flappyBirdColor: BirdColor.values[Random().nextInt(3)],
      flappyBirdFlightStage: FlightStage.mid,
      flappyBirdIsJumping: false,
      flappyBirdDir: 1,
      heightToJump: 0,
    };
    // player velocity, max velocity, downward acceleration, acceleration on flap
    playerVelY = -9; // player's velocity along Y, default same as playerFlapped
  }
}
