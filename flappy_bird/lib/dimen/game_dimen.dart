//todo change the x and y to w and h where reasonable
const _screenHeight = 696.0;
const _screenWidth = 392.0;
const screenDimen = {'x': _screenWidth, 'y': _screenHeight};
const flappyBirdDimen = {'x': 65.0, 'y': 45.0};
final flappyBirdStartingPos = {
  'x': screenDimen['x']! * .2,
  'y': gameAreaHeight / 2
};
const backgroundDimen = {'x': _screenWidth, 'y': _screenHeight};
const baseDimen = {'x': _screenWidth + 20, 'y': 140.0};
const baseXOffset = 30;
const welcomeMessageDimen = {'x': 250.0, 'y': 362.0};
const pipeGapVertical = 150.0;
const pipeHeight = 320.0;
const pipeWidth = 52.0;
const pipeGapHorizontal = pipeWidth + 150;
const minPipeHeight = 161.0;
final gameAreaHeight = _screenHeight - baseDimen['y']!;
const maxPipeHeight = 320;
