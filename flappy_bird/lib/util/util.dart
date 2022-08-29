import 'dart:math';

import 'package:flutter/material.dart';

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

  double dp(BuildContext context) {
    print(this);
    final toReturn = this / MediaQuery.of(context).devicePixelRatio;
    print(toReturn);
    print('');
    return toReturn;
  }
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
