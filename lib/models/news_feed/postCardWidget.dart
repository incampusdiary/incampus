import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:incampusdiary/models/news_feed/swiping_position_provider.dart';

class PostCardWidget extends StatelessWidget {
  final imageFile;
  final PostModel postFile;

  const PostCardWidget({
    @required this.imageFile,
    this.postFile,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    /// imageFile != null -> ImagePost
    /// imageFile == null && postFile?.get('mediaUrl') == '' -> Written Article
    /// imageFile == null -> No More Posts

    if (imageFile != null) {
      return Material(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            image: DecorationImage(
                image: FileImage(imageFile),
                // Todo: Uncomment this line when all previous articles are deleted from database:
                // fit: post.isFullScreen ? BoxFit.fill : BoxFit.contain,
                fit: BoxFit.fill),
            color: Colors.white,
          ),
        ),
      );
    }
  }

  Widget buildLikeBadge(SwipingDirection swipingDirection) {
    final isSwipingRight = swipingDirection == SwipingDirection.right;
    final color = isSwipingRight ? Colors.green : Colors.pink;
    final angle = isSwipingRight ? -0.5 : 0.5;

    if (swipingDirection == SwipingDirection.none) {
      return Container();
    } else {
      return Positioned(
        top: 20,
        right: isSwipingRight ? null : 20,
        left: isSwipingRight ? 20 : null,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              isSwipingRight ? 'LIKE' : 'NOPE',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }
}
