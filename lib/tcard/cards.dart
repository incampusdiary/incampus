import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:incampusdiary/activity_feed/news_feed_astra.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';

import '../constants.dart';
import 'animations.dart';
import 'controller.dart';
import 'swip_info.dart';

typedef ForwardCallback(int index, SwipInfo info);
typedef BackCallback(int index, SwipInfo info);
typedef EndCallback();

class TCard extends StatefulWidget {
  Size size;

  ForwardCallback onForward;

  BackCallback onBack;

  EndCallback onEnd;

  TCardController controller;

  bool lockYAxis;

  double slideSpeed;

  int delaySlideFor;

  TCard({
    this.controller,
    this.onForward,
    this.onBack,
    this.onEnd,
    this.lockYAxis = false,
    this.slideSpeed = 20,
    this.delaySlideFor = 500,
    this.size = const Size(380, 400),
  });

  @override
  TCardState createState() => TCardState();
}

int frontCardIndexRef = 0;

class TCardState extends State<TCard> with TickerProviderStateMixin {
  List<SwipInfo> _swipInfoList = [];

  List<SwipInfo> get swipInfoList => _swipInfoList;

  bool isCardMoving = false;

  int _frontCardIndex = 0;

  int get frontCardIndex => _frontCardIndex;

  Alignment _frontCardAlignment = CardAlignments.front;

  double _frontCardRotation = 0.0;

  AnimationController _cardChangeController;
  AnimationController _cardReverseController;
  Animation<Alignment> _reboundAnimation;
  AnimationController _reboundController;

  Widget _frontCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < carouselList.length
        ? carouselList[_frontCardIndex].tempPostCardWidget
        : hasNoMorePosts
            ? Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: Colors.blueAccent,
                  ),
                  child: Center(
                    child: Text(
                      'No More Post to Show!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            : Container();
    if (_frontCardIndex < carouselList.length) {
      // post = postModelList.elementAt(_frontCardIndex);
      post = carouselList[_frontCardIndex].tempPostDocument;
    }
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    // print('isAnimating: ${_isAnimating()}');
    Widget rotate = Transform.rotate(
      angle: (math.pi / 180.0) * _frontCardRotation,
      child: SizedBox.fromSize(
        size: isCardMoving
            ? CardSizes.frontDuringAnimation(constraints)
            : CardSizes.front(constraints),
        child: child,
      ),
    );
    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.frontCardShowAnimation(
          _cardReverseController,
          CardAlignments.front,
          _swipInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.frontCardDisappearAnimation(
          _cardChangeController,
          _frontCardAlignment,
          _swipInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else {
      return Align(
        alignment: _frontCardAlignment,
        child: rotate,
      );
    }
  }

  Widget _middleCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < carouselList.length - 1
        ? carouselList[_frontCardIndex + 1].tempPostCardWidget
        : Container();

    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.middleCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.middleCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.middleCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.middleCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.middle,
        child: SizedBox.fromSize(
          size: CardSizes.middle(constraints),
          child: child,
        ),
      );
    }
  }

  Widget _backCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < carouselList.length - 2
        ? carouselList[_frontCardIndex + 2].tempPostCardWidget
        : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.backCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.backCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.backCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.backCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.back,
        child: SizedBox.fromSize(
          size: CardSizes.back(constraints),
          child: child,
        ),
      );
    }
  }

  bool _isAnimating() {
    return _cardChangeController.status == AnimationStatus.forward ||
        _cardReverseController.status == AnimationStatus.forward;
  }

  void _runReboundAnimation(Offset pixelsPerSecond, Size size) {
    print('Rebound Animation');

    isCardMoving = false;

    _reboundAnimation = _reboundController.drive(
      AlignmentTween(
        begin: _frontCardAlignment,
        end: CardAlignments.front,
      ),
    );

    double unitsPerSecondX = pixelsPerSecond.dx / size.width;
    double unitsPerSecondY = pixelsPerSecond.dy / size.height;
    var unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    var unitVelocity = unitsPerSecond.distance;
    var spring = SpringDescription(mass: 30.0, stiffness: 1.0, damping: 1.0);
    var simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _reboundController.animateWith(simulation);
    _resetFrontCard();
  }

  void _runChangeOrderAnimation() {
    if (_isAnimating()) {
      return;
    }

    if (_frontCardIndex >= carouselList.length) {
      return;
    }

    _cardChangeController.reset();
    _cardChangeController.forward();
  }

  get runChangeOrderAnimation => _runChangeOrderAnimation;

  void _runReverseOrderAnimation() {
    if (_isAnimating()) {
      return;
    }

    if (_frontCardIndex == 0) {
      _swipInfoList.clear();
      return;
    }

    _cardReverseController.reset();
    _cardReverseController.forward();
  }

  get runReverseOrderAnimation => _runReverseOrderAnimation;

  void _forwardCallback() {
    print('Forward CallBack Called');

    _frontCardIndex++;
    frontCardIndexRef++;

    addMoreData(_swipInfoList[_frontCardIndex - 1].direction);

    _resetFrontCard();

    if (widget.onForward != null && widget.onForward is Function) {
      widget.onForward(
        _frontCardIndex,
        _swipInfoList[_frontCardIndex - 1],
      );
    }

    if (widget.onEnd != null &&
        widget.onEnd is Function &&
        _frontCardIndex >= carouselList.length) {
      widget.onEnd();
    }

    isCardMoving = false;
    print('Forward Call Complete');
  }

  void _backCallback() {
    _resetFrontCard();
    _swipInfoList.removeLast();
    if (widget.onBack != null && widget.onBack is Function) {
      int index = _frontCardIndex > 0 ? _frontCardIndex - 1 : 0;
      SwipInfo info = _swipInfoList.isNotEmpty
          ? _swipInfoList[index]
          : SwipInfo(-1, SwipDirection.None);

      widget.onBack(_frontCardIndex, info);
    }
  }

  void _resetFrontCard() {
    _frontCardRotation = 0.0;
    _frontCardAlignment = CardAlignments.front;

    setState(() {});
  }

  void reset({List<Widget> cards}) {
    cards.clear();
    if (cards != null) {
      cards.addAll(cards);
    } else {
      carouselList.forEach((element) {
        cards.add(element.tempPostCardWidget);
      });
    }
    _swipInfoList.clear();
    _frontCardIndex = 0;
    frontCardIndexRef = 0;
    _resetFrontCard();
  }

  void _stop() {
    _reboundController.stop();
    _cardChangeController.stop();
    _cardReverseController.stop();
  }

  void _updateFrontCardAlignment(DragUpdateDetails details, Size screenSize) {
    _frontCardAlignment += Alignment(
      details.delta.dx / (screenSize.width) * widget.slideSpeed,
      widget.lockYAxis
          ? 0
          : details.delta.dy /
              ((screenSize.height * 0.5) / 2) *
              widget.slideSpeed,
    );

    _frontCardRotation = _frontCardAlignment.x;
    setState(() {});
  }

  void _judgeRunAnimation(DragEndDetails details, Size size) {
    print('_judgeRunAnimation()');
    double limit = hasNoMorePosts ? 100 : 10.0;
    if (frontCardIndex == carouselList.length) {
      _runReboundAnimation(details.velocity.pixelsPerSecond, size);
      return;
    }

    bool isSwipLeft =
        _frontCardAlignment.x < -limit || details.primaryVelocity < -500;
    bool isSwipRight =
        _frontCardAlignment.x > limit || details.primaryVelocity > 500;

    if ((hasNoMorePosts || frontCardIndex < carouselList.length - 1) &&
        (isSwipLeft || isSwipRight)) {
      print('Swipe');

      _runChangeOrderAnimation();
      if (isSwipLeft) {
        _swipInfoList.add(SwipInfo(_frontCardIndex, SwipDirection.Left));
      } else {
        _swipInfoList.add(SwipInfo(_frontCardIndex, SwipDirection.Right));
      }
    } else {
      if (_frontCardIndex >= carouselList.length - 1) {
        showToast(message: 'Loading More Posts...');
      }
      _runReboundAnimation(details.velocity.pixelsPerSecond, size);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.controller is TCardController) {
      widget.controller.bindState(this);
    }

    _cardChangeController = AnimationController(
      duration: Duration(milliseconds: widget.delaySlideFor),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _forwardCallback();
        }
      });

    _cardReverseController = AnimationController(
      duration: Duration(milliseconds: widget.delaySlideFor),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _frontCardIndex--;
          frontCardIndexRef--;
        } else if (status == AnimationStatus.completed) {
          _backCallback();
        }
      });

    _reboundController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.delaySlideFor),
    )..addListener(() {
        setState(() {
          _frontCardAlignment = _reboundAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _cardReverseController.dispose();
    _cardChangeController.dispose();
    _reboundController.dispose();
    if (widget.controller != null) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: MediaQuery.of(context).size,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          Size size = MediaQuery.of(context).size;
          return Stack(
            children: <Widget>[
              _backCard(constraints),
              _middleCard(constraints),
              _frontCard(constraints),
              _cardChangeController.status != AnimationStatus.forward
                  ? SizedBox.expand(
                      child: GestureDetector(
                        onHorizontalDragDown: (DragDownDetails details) {
                          _stop();
                          isCardMoving = true;
                        },
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          _updateFrontCardAlignment(details, size);
                        },
                        onHorizontalDragEnd: (DragEndDetails details) {
                          _judgeRunAnimation(details, size);
                        },
                      ),
                    )
                  : IgnorePointer(),
            ],
          );
        },
      ),
    );
  }

  showTransparentScreen(nextScreen) {
    Navigator.of(context).push(
      PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.75),
          transitionDuration: Duration(milliseconds: 500),
          reverseTransitionDuration: Duration(milliseconds: 250),
          //Todo: Add Animation here
          // transitionsBuilder: ,
          pageBuilder: (context, _, __) => nextScreen),
    );
  }
}

class SavePost extends StatelessWidget {
  final PostModel postFile;
  const SavePost({@required this.postFile});

  @override
  Widget build(BuildContext context) {
    timer(context);

    var savedPostId = (postFile.mediaUrl == "")
        ? "${postFile.postId}-a"
        : "${postFile.postId}-p";

    var isSavedPost = savedPosts.contains(savedPostId);

    if (isSavedPost) {
      savedPosts.remove(savedPostId);
    } else
      savedPosts.add(savedPostId);

    print(savedPosts);
  }

  void timer(context) async {
    await Future.delayed(
      Duration(
        milliseconds: 1300,
      ),
    );
    Navigator.pop(context);
  }
}
