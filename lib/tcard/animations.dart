import 'package:flutter/material.dart';
import 'swip_info.dart';

/* Card Sizes */
class CardSizes {
  static Size front(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  static Size frontDuringAnimation(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.9, constraints.maxHeight);
  }

  static Size middle(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.55, constraints.maxHeight * 0.55);
  }

  static Size back(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.45, constraints.maxHeight * .45);
  }
}

/* Card Alignments */
class CardAlignments {
  static Alignment front = Alignment(0.0, 0.0);
  static Alignment middle = Alignment(0.0, 0.0);
  static Alignment back = Alignment(0.0, 0.0);
}

/* Card Forward Animations */
class CardAnimations {
  static Animation<Alignment> frontCardDisappearAnimation(
    AnimationController parent,
    Alignment beginAlignment,
    SwipInfo info,
  ) {
    return AlignmentTween(
      begin: beginAlignment,
      end: Alignment(
        info.direction == SwipDirection.Left
            ? beginAlignment.x - 30.0
            : beginAlignment.x + 30.0,
        0.0,
      ),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> middleCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.middle,
      end: CardAlignments.front,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> middleCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.middle(constraints),
      end: CardSizes.front(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.1, 1.0, curve: Curves.bounceOut),
      ),
    );
  }

  static Animation<Alignment> backCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.back,
      end: CardAlignments.middle,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> backCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.back(constraints),
      end: CardSizes.middle(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }
}

/* Card Backward Animations */
class CardReverseAnimations {
  static Animation<Alignment> frontCardShowAnimation(
    AnimationController parent,
    Alignment endAlignment,
    SwipInfo info,
  ) {
    print(
        '\n\nend $endAlignment ${info.direction == SwipDirection.Left ? endAlignment.x - 30.0 : endAlignment.x + 30.0}');
    return AlignmentTween(
      begin: Alignment(
        info.direction == SwipDirection.Left
            ? endAlignment.x - 30.0
            : endAlignment.x + 30.0,
        0.0,
      ),
      end: endAlignment,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> middleCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.front,
      end: CardAlignments.middle,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> middleCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.front(constraints),
      end: CardSizes.middle(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> backCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.middle,
      end: CardAlignments.back,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> backCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.middle(constraints),
      end: CardSizes.back(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }
}
