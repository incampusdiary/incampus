import 'package:flutter/cupertino.dart';

class SwipeDetector extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final Function onLongPress;
  final Function onSwipeUp;
  final Function onSwipeDown;

  SwipeDetector({
    this.child,
    this.onTap,
    this.onLongPress,
    this.onSwipeUp,
    this.onSwipeDown,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onVerticalDragEnd: (details) {
        print('Vertical:${details.velocity}');

        double dx = details.velocity.pixelsPerSecond.dx.abs();
        double dy = details.primaryVelocity;
        if (dy > 100) {
          if (dx > 30 || dy > 300) {
            print('Swiped Down');
            onSwipeDown?.call();
          }
        } else if (-dy > 100) {
          if (dx > 30 || -dy > 300) {
            print('Swiped Up');
            onSwipeUp?.call();
          }
        }
      },
      onTap: () {
        print("Tapped");
        onTap?.call();
      },
      onLongPress: () {
        print("Long Press");
        onLongPress?.call();
      },
    );
  }
}
