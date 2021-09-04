import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:incampusdiary/activity_feed/post_description.dart';
import 'package:incampusdiary/activity_feed/profile.dart';
import 'package:incampusdiary/models/news_feed/postCardWidget.dart';
import 'package:incampusdiary/models/news_feed/swiping_position_provider.dart';
import 'package:incampusdiary/screens/home_screen.dart';
import 'package:incampusdiary/services/swipedetector.dart';
import 'package:incampusdiary/tcard/cards.dart';
import 'package:incampusdiary/tcard/controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:incampusdiary/activity_feed/upload.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import '../models/news_feed/news_feed_data_model.dart';
import 'package:provider/provider.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'comments.dart';
import 'news_feed_home.dart';

class NewsFeed extends StatefulWidget {
  static final id = "news_feed";

  @override
  _NewsFeedState createState() => _NewsFeedState();
}

PostModel post = PostModel();

var database = FirebaseDatabase.instance.reference()..keepSynced(true);
var firestore = FirebaseFirestore.instance;
var firebase = FirebaseAuth.instance;

final nextDownloadWindowSize = 3;
final paginationLimitNumber = 6;
var lastReceivedDoc;

List<WidgetList> carouselList = [];
List<PostModel> postModelList = [];

List savedPosts = [];

/** Contains posts that the user has never visited before,
 * and hence must be shown whenever this list is not empty.  */
Queue<PostModel> postsToBeShownNow = Queue();

/** Contains posts that the user has already visited,
 * and so will be shown whenever no new posts will be available. */
PriorityQueue<PostModel> postsToBeShownLater = PriorityQueue((e0, e1) {
  var _random = Random();
  var randomSelected = _random.nextInt(2) + 1;

  return randomPrioritySelection(randomSelected, e0, e1);
});

/** Contains all posts that the user has visited,
 * liked and successfully stored on realtime database. */
Map alreadyVisitedPosts, postLikes, postDislikes;

likeDislikeRatio(post) {
  return (postLikes[post.postId] ?? 0) / (postDislikes[post.postId] ?? 0);
}

randomPrioritySelection(randomSelected, post1, post2) {
  switch (randomSelected) {
    case 1:
      {
        return likeDislikeRatio(post1) > likeDislikeRatio(post2) ? 1 : -1;
      }
    case 2:
      {
        return post1.comments.length > post2.comments.length ? 1 : -1;
      }
  }
}

bool hasNoMorePosts = false;
bool noMorePostToFetch = false;

// List<Widget> widgetList = [];

class _NewsFeedState extends State<NewsFeed> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    post = postModelList.first;
    print(post.title);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    final isBackground = state == AppLifecycleState.paused;

    if (isBackground) {
      database
          .child('alreadyVisited')
          .child(firebase.currentUser.uid)
          .set(alreadyVisitedPosts);
      updateComments();
      updateSavedPosts();
    } else {
      //Can call functions here when the app resumes again.
    }
  }

  @override
  Widget build(BuildContext context) {
    print('NewsFeed Build Called');

    print('In NewsFeed');
    print(post.description);

    database
        .child('alreadyVisited')
        .child(firebase.currentUser.uid)
        .onDisconnect()
        .set(alreadyVisitedPosts);

    TCardController swipeController = TCardController();

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black54,
        resizeToAvoidBottomInset: false,
        floatingActionButton: Consumer<NewsFeedData>(
          builder: (context, newsFeedData, child) {
            return newsFeedData.speedDialVisibility
                ? SpeedDial(
                    child: Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.white,
                    ),
                    closedForegroundColor: Colors.grey,
                    openForegroundColor: Colors.blueAccent,
                    closedBackgroundColor: Colors.blueAccent,
                    openBackgroundColor: Colors.grey,
                    speedDialChildren: <SpeedDialChild>[
                      SpeedDialChild(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          label: 'Upload',
                          onPressed: () {
                            firstVisitInUpload = true;
                            Navigator.pushNamed(context, Upload.id);
                          }),
                      SpeedDialChild(
                        child: SvgPicture.asset(
                          'images/meme.svg',
                          width: 15,
                          height: 24,
                          color: Colors.black,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.yellow[100],
                        label: 'Memes',
                        onPressed: () {},
                      ),
                      SpeedDialChild(
                        child: SvgPicture.asset(
                          'images/selfie.svg',
                          width: 18,
                          height: 18,
                          color: Colors.white,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pinkAccent,
                        label: 'Selfie',
                        onPressed: () {},
                      ),
                      SpeedDialChild(
                        child: SvgPicture.asset(
                          'images/art.svg',
                          width: 15,
                          height: 24,
                          color: Colors.white,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        label: 'Art',
                        onPressed: () {},
                      ),
                      SpeedDialChild(
                        child: SvgPicture.asset(
                          'images/article.svg',
                          width: 18,
                          height: 24,
                          color: Colors.white,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        label: 'Articles',
                        onPressed: () {},
                      ),
                    ],
                  )
                : SizedBox();
          },
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SwipeDetector(
                onTap: () {
                  if (!hasNoMorePosts) {
                    // providerFalse.toggleSpeedDialVisibility();
                    showTransparentScreen(PostDescription(postFile: post));
                  }
                },
                onLongPress: () {
                  if (!hasNoMorePosts) {
                    showTransparentScreen(SavePost(postFile: post));
                  }
                },
                onSwipeUp: () {
                  if (!hasNoMorePosts) {
                    // providerFalse.toggleSpeedDialVisibility();
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        barrierColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        elevation: 20,
                        context: context,
                        builder: (context) => Comments());
                  }
                },
                onSwipeDown: () {
                  showTransparentScreen(NewsFeedHome());
                },
                child: !hasNoMorePosts
                    ? TCard(
                        controller: swipeController,
                        size: Size(width, height),
                        lockYAxis: true,
                      )
                    : Center(
                        child: Container(
                          height: height,
                          width: width,
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
                      ),
              ),
            ),
            (post.mediaUrl != "")
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Profile(userId: post.userId),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(currentUser.photoURL),
                          radius: 24,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            // Todo: Try adding Like/Dislike badge here
          ],
        ),
      ),
    );
  }

  fetchFreshPostsAfterAppLaunch() async {
    var retrieveInfo = await firestore
        .collection("posts")
        .orderBy("timestamp")
        .limit(paginationLimitNumber)
        .get();

    retrieveInfo.docs.forEach((element) {
      PostModel postModelRef = PostModel();
      postModelRef.fromJson(element);
      postModelList.add(postModelRef);
    });

    lastReceivedDoc = retrieveInfo.docs.last;
  }

  showTransparentScreen(nextScreen) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.75),
        transitionDuration: Duration(seconds: 1),
        reverseTransitionDuration: Duration(milliseconds: 250),
        //Todo: Add Animation here
        // transitionsBuilder: ,
        pageBuilder: (context, _, __) => nextScreen));
  }
}

Widget buildPost(imageFile, {file = null}) {
  return PostCardWidget(
    imageFile: imageFile,
    postFile: file,
  );
}

fetchGetList() async {
  var retrieveInfo = await firestore
      .collection("posts")
      .orderBy("timestamp", descending: true)
      .startAfterDocument(lastReceivedDoc)
      .limit(paginationLimitNumber)
      .get();

  retrieveInfo.docs.forEach((element) {
    PostModel postModelRef = PostModel();
    postModelRef.fromJson(element);
    if (alreadyVisitedPosts.containsKey(postModelRef.postId)) {
      postsToBeShownLater.add(postModelRef);
    } else
      postsToBeShownNow.add(postModelRef);
  });

  if (retrieveInfo.size > 0)
    lastReceivedDoc = retrieveInfo.docs.last;
  else
    noMorePostToFetch = true;

  var postToBeShownNowLength = postsToBeShownNow.length;

  print('postsToBeShownLater: ${postsToBeShownLater.length}');

  if (postsToBeShownNow.isEmpty) {
    print('No new posts currently');
    addFirstFive(postsToBeShownLater);
  } else if (postsToBeShownNow.length < 5) {
    print('Less than 5 new posts present');

    postModelList.addAll(postsToBeShownNow);
    for (int i = 0;
        i < (5 - postToBeShownNowLength) && postsToBeShownLater.isNotEmpty;
        i++) {
      postModelList.add(postsToBeShownLater.removeFirst());
    }
    postsToBeShownNow.clear();
  } else {
    print('All new posts');
    for (int i = 0; i < postToBeShownNowLength; i++) {
      postModelList.add(postsToBeShownNow.removeFirst());
    }
    postsToBeShownNow.clear();
  }
}

void nextPage() async {
  print('Current PostIndex : ${postModelList.length}  $frontCardIndexRef');

  if (postModelList.length - frontCardIndexRef > 1) {
    if (postModelList.length - frontCardIndexRef == 3) {
      print('Fetch More Posts to PostModelList');
      await fetchGetList();
    }

    /* Downloading the next few posts' image in advance */
    int downloadableScope = nextDownloadWindowSize + frontCardIndexRef - 1;
    print("Before Downloadable Scope Checking");

    if (downloadableScope < postModelList.length) {
      if (postModelList.elementAt(downloadableScope).mediaUrl != '') {
        print('New Download : $downloadableScope <-> $frontCardIndexRef');
        await download(postModelList[downloadableScope]);
      } else {
        print('File is a Article !!!');

        WidgetList _widgetList = WidgetList();
        _widgetList.tempPostDocument = postModelList[downloadableScope];
        _widgetList.tempPostCardWidget =
            buildPost(null, file: postModelList[downloadableScope]);
        carouselList.add(_widgetList);
      }

      if (noMorePostToFetch && downloadableScope + 1 >= postModelList.length) {
        print('No More post to Download');
        // hasNoMorePosts = true;
      }
    }
  } else {
    print('No More Posts');
    hasNoMorePosts = true;
  }
}

addMoreData(swipeDirection) {
  print('Inside Add More Data');
  print(swipeDirection);

  if (!alreadyVisitedPosts.containsKey(post.postId)) {
    try {
      if (swipeDirection == SwipingDirection.left) {
        database
            .child('likes')
            .child(post.postId)
            .set(ServerValue.increment(1));
        alreadyVisitedPosts[post.postId] = true;
      } else {
        database
            .child('dislikes')
            .child(post.postId)
            .set(ServerValue.increment(1));
        alreadyVisitedPosts[post.postId] = false;
      }
    } catch (e) {
      print('Exception occurred while incrementing likes: $e');
    }
    print('\n\n$alreadyVisitedPosts');
  }
  updateComments();
  nextPage();
}

updateSavedPosts() {
  firestore
      .collection('userInfo')
      .doc(currentUser.uid)
      .set({'savedPosts': savedPosts});
}

updateComments([int tryAgain = 0, bool additionSuccessful = true]) async {
  if ((hasCommentsBeenAdded || hasCommentsBeenEdited) && tryAgain < 5) {
    print(
        'Add: $hasCommentsBeenAdded  Edited: $hasCommentsBeenEdited  Deleted: $hasCommentsBeenDeleted');
    print('Added comments: $addedComments');
    additionSuccessful = false;
    try {
      await firestore.collection('posts').doc(post.postId).set(
        {
          'comments': FieldValue.arrayUnion(addedComments),
        },
        SetOptions(merge: true),
      );
      hasCommentsBeenAdded = false;
      additionSuccessful = true;
    } catch (e) {
      print('Exception Caught while Adding comments: $e');
      print('Trying Again: $tryAgain');
      updateComments(++tryAgain, additionSuccessful);
    }
  }

  if ((hasCommentsBeenDeleted || hasCommentsBeenEdited) &&
      additionSuccessful //To ensure that edited comments are not deleted if their addition was unsuccessful.
      &&
      tryAgain < 10) {
    print(
        'Add: $hasCommentsBeenAdded  Edited: $hasCommentsBeenEdited  Deleted: $hasCommentsBeenDeleted');
    print('Deleted Comments: $deletedComments');
    try {
      await firestore.collection('posts').doc(post.postId).set(
        {
          'comments': FieldValue.arrayRemove(deletedComments),
        },
        SetOptions(merge: true),
      );
      hasCommentsBeenDeleted = hasCommentsBeenEdited = false;
    } catch (e) {
      print('Exception Caught while Deleting comments: $e');
      print('Trying Again: $tryAgain');
      updateComments(++tryAgain, additionSuccessful);
    }
  }

  updateSavedPosts();

  addedComments.clear();
  deletedComments.clear();
}

addFirstFive(list) {
  for (int i = 0; i < 5 && list.isNotEmpty; i++) {
    postModelList.add(list.removeFirst());
  }
  print('Exiting addFirstFive: ${list.length}');
}

class WidgetList {
  Widget tempPostCardWidget;
  PostModel tempPostDocument;
}
