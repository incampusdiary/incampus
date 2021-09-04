import 'package:flutter/material.dart';

enum SwipingDirection { left, right, none }

class SwipingPositionProvider extends ChangeNotifier {
  double _dx = 0.0;
  SwipingDirection _swipingDirection = SwipingDirection.none;

  SwipingDirection get swipingDirection => _swipingDirection;

  SwipingPositionProvider() {
    _swipingDirection = SwipingDirection.none;
  }

  void resetPosition() {
    _dx = 0.0;
    _swipingDirection = SwipingDirection.none;
    notifyListeners();
  }

  void updatePosition(double changeInX) {
    _dx = _dx + changeInX;
    if (_dx > 0) {
      _swipingDirection = SwipingDirection.right;
    } else if (_dx < 0) {
      _swipingDirection = SwipingDirection.left;
    } else {
      _swipingDirection = SwipingDirection.none;
    }
    notifyListeners();
  }
}
