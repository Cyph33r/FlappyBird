import 'dart:async';
import 'dart:math';

import 'package:flappy_bird/widgets/flappy_bird.dart';
import 'package:flappy_bird/widgets/pipe.dart';
import 'package:flutter/material.dart';
import 'util/util.dart';

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({Key? key}) : super(key: key);

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame> {
  double flappyBirdYAxis = 0;
  var direction = 1;
  var gameStarted = false;
  var flightStage = FlightStage.up;
  var flyingTimeLeft = 0.0;
  var pipeLocationOnTheScreen = 0.0;
  final numOfPipesOnScreen = 2;
  final pipe = Pipe(62);
  double width = 0;
  final pipeSpeed = 5;
  BirdColor birdColor = BirdColor.values[Random().nextInt(3)];
  final double flyingDuration = .1;

  double xAlignment = 1;
  double yAlignment = 1;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 166), (timer) {
      if (!gameStarted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gameStarted && flappyBirdYAxis.inRange(-1, 1)) {
      width = MediaQuery.of(context).size.width;
      pipeLocationOnTheScreen = pipeLocationOnTheScreen - pipeSpeed < -124
          ? width + 124
          : pipeLocationOnTheScreen - pipeSpeed;
      // print(
      //     "pipe:${pipeLocationOnTheScreen.convertToAlignment(
      //         width)} bird:$flappyBirdYAxis");
      if (flappyBirdYAxis == -1 && flyingTimeLeft > 0) {
        flyingTimeLeft = 0;
      }
      if (flyingTimeLeft > 0) {
        flappyBirdYAxis = (flappyBirdYAxis - .045).constrain(-1, 1);
        if (flyingTimeLeft > 0) {
          flyingTimeLeft -= .02;
        }
      }

      if (flyingTimeLeft <= 0) {
        flappyBirdYAxis = (flappyBirdYAxis + .025).constrain(-1, 1);
      }

      if (direction == -1) {
      } else if (direction == 1) {
      } else {
        throw AssertionError("direction has an illegal value: $direction");
      }
    }
    // print(pipeLocationOnTheScreen.convertToAlignment(width));
    updatePipe();
    updateBird();
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (_) => jump(),
            onTapUp: (_) => stopJump(),
            onLongPressDown: (_) => jump(),
            onLongPressUp: stopJump,
            // stopJump,
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/background-day.png"),
                                  fit: BoxFit.cover)),
                        ),
                        AnimatedContainer(
                          alignment: Alignment(
                              pipeLocationOnTheScreen.convertToAlignment(width),
                              0),
                          duration: Duration.zero,
                          child: pipe,
                        ),
                        AnimatedContainer(
                          alignment: Alignment(0, flappyBirdYAxis),
                          duration: Duration.zero,
                          child: FlappyBird(
                            birdColor: birdColor,
                            flightStage: flightStage,
                          ),
                        ),
                        AnimatedContainer(duration: Duration.zero, child: pipe),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  "assets/images/base.png",
                  fit: BoxFit.fill,
                  width: double.infinity,
                )
              ],
            ),
          ),
          if (!gameStarted)
            GestureDetector(
              onTap: startGame,
              child: const StartScreen(),
            ),
        ],
      ),
    );
  }

  void jump() {
    flightStage = FlightStage.down;
    flyingTimeLeft = flyingDuration;
  }

  void stopJump() {}

//todo:change pipe size here
  void updatePipe() {}

  void updateBird() {
    const cycle = [0, 1, 2, 1];
    final flightStageIndex = (flightStage.index + 1) % 3;
    flightStage = FlightStage.values[flightStageIndex];
  }

  void startGame() {
    setState(() {
      gameStarted = true;
    });
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x77000000),
      child: const Center(
        child: Text(
          "PRESS TO START",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}

class GreenBackground extends StatelessWidget {
  const GreenBackground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green);
  }
}
