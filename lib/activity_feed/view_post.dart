import 'package:flutter/material.dart';
import 'package:incampusdiary/activity_feed/comments.dart';
import 'package:incampusdiary/activity_feed/post_description.dart';
import 'package:incampusdiary/activity_feed/profile.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:incampusdiary/services/swipedetector.dart';
import 'package:incampusdiary/tcard/cards.dart';
import 'article_viewer.dart';

class ViewPost extends StatefulWidget {
  final PostModel postFile;

  const ViewPost({this.postFile});

  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          PostCard(postFile: widget.postFile),
          SizedBox.expand(
            child: SwipeDetector(
              onTap: () {
                showTransparentScreen(
                    PostDescription(postFile: widget.postFile));
              },
              onLongPress: () {
                showTransparentScreen(SavePost(postFile: widget.postFile));
              },
              onSwipeUp: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    barrierColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    enableDrag: true,
                    elevation: 20,
                    context: context,
                    builder: (context) => Comments());
              },
            ),
          ),
          (widget.postFile.userId != currentUser.uid)
              ? Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              Profile(userId: widget.postFile.userId),
                        ),
                      );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(currentUser.photoURL),
                        radius: 18,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
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

class PostCard extends StatelessWidget {
  final PostModel postFile;

  PostCard({@required this.postFile});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (postFile.mediaUrl != '') {
      return Material(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            image: DecorationImage(
              image: NetworkImage(postFile.mediaUrl),
              fit: postFile.isFullScreen ? BoxFit.fill : BoxFit.contain,
            ),
            color: Colors.white,
          ),
        ),
      );
    } else {
      return ArticleViewer(postFile: postFile);
    }
  }
}
