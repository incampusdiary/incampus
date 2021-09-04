enum SwipDirection {
  Left,
  Right,
  None,
}

class SwipInfo {
  int cardIndex;
  SwipDirection direction;

  SwipInfo(
    this.cardIndex,
    this.direction,
  );
}
