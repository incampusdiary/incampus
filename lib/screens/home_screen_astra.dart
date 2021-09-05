import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/activity_feed/comments.dart';
import 'package:incampusdiary/activity_feed/news_feed_astra.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:incampusdiary/rounded_button.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:incampusdiary/services/google.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'dart:math';
import '../widgets.dart';

class HomeScreen extends StatefulWidget {
  static final id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

var postHeight, postWidth;
var currentUserId = currentUser.uid;

class _HomeScreenState extends State<HomeScreen> {
  final _database = FirebaseFirestore.instance;
  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    print('Astra');
    print(DateTime.now());
    fetchAlreadyVisitedPosts();
    fetchPostLikesDislikes();
    fetchSavedPosts();
  }

  @override
  Widget build(BuildContext context) {
    postHeight = MediaQuery.of(context).size.height;
    postHeight = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF4364F7), Color(0xFF6FB1FC)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "logo",
                child: animatedLogoTitle('InCampus Diary_', 40),
              ),
              logoSubtitle(),
              connectNowButton(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: RoundedButton(
                    title: 'Log Out',
                    onPressed: () {
                      signOutGoogle();
                    }),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
                child:
                    colorizedAnimatedText('An AtmaNirbhar Bharat Initiative'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Download Image from URL
download(PostModel downloadablePost) async {
  String url = downloadablePost.mediaUrl;
  var _url = Uri.parse(url);
  final response = await http.get(_url);

  /// Get the image name
  final imageName = path.basename(url);

  /// Get the document directory path
  final appDir = await pathProvider.getApplicationDocumentsDirectory();

  /// This is the saved image path. You can use it to display the saved image later.
  final localPath = path.join(appDir.path, imageName);

  /// Downloading
  final imageFile = File(localPath);
  await imageFile.writeAsBytes(response.bodyBytes);
  print('Download | ${DateTime.now()}');
  WidgetList _widgetList = WidgetList();
  _widgetList.tempPostCardWidget = buildPost(imageFile);
  _widgetList.tempPostDocument = downloadablePost;
  carouselList.add(_widgetList);
}

fetchFirstGetList() async {
  print('Entered fetchFirst');

  var retrieveInfo = await firestore
      .collection("posts")
      .orderBy("timestamp", descending: true)
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

  lastReceivedDoc = retrieveInfo.docs.last;

  print(Timestamp.now());
  print(DateTime.now());

  if (postsToBeShownNow.isEmpty) {
    print('No new posts currently');
    addFirstFive(postsToBeShownLater);
  } else {
    print('New posts: ${postsToBeShownNow.length}');
    print('Old posts: ${postsToBeShownLater.length}');

    var postToBeShownNowLength = postsToBeShownNow.length;
    for (int i = 0; i < postToBeShownNowLength; i++) {
      postModelList.add(postsToBeShownNow.removeFirst());
    }

    print('Before PostModeList Size : ${postModelList.length}');
    for (int i = 0;
        i < 5 - postToBeShownNowLength && postsToBeShownLater.isNotEmpty;
        i++) {
      postModelList.add(postsToBeShownLater.removeFirst());
    }
    postsToBeShownNow.clear();
  }

  print('After PostModeList Size : ${postModelList.length}');

  for (int i = 0; i < min(nextDownloadWindowSize, postModelList.length); i++) {
    if (postModelList.elementAt(i).mediaUrl != '') {
      await download(postModelList.elementAt(i));
    } else {
      print("An article found!");
      WidgetList _widgetList = WidgetList();
      _widgetList.tempPostDocument = postModelList.elementAt(i);
      _widgetList.tempPostCardWidget =
          buildPost(null, file: postModelList.elementAt(i));
      carouselList.add(_widgetList);
    }
  }

  print('Exit fetchFirst   ${carouselList.length}');
  print(Timestamp.now());
  print(DateTime.now());
}

fetchAlreadyVisitedPosts() async {
  var temp = await getDataFromAstra('alreadyVisitedPosts/$currentUserId');
  print('\n\ntemp: $temp');
  fetchFirstGetList();
}

getDataFromAstra(urlEndPoint) async {
  final url = '$headerUrl/$urlEndPoint';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
        "Content-Type": "application/json"
      },
    );
    print('response ${response.body}');
    if (response.statusCode == 200)
      return json.decode(response.body)['data'];
    else
      return {};
  } catch (error) {
    print('Exception Caught | getAlreadyVisitedPosts() |\n $error');
  }
}

fetchPostLikesDislikes() async {
  final url =
      'https://$ASTRA_DB_ID-$ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/keyspaces/$ASTRA_DB_KEYSPACE/likes/rows';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
        "Content-Type": "application/json",
      },
    );
    print("Get Likes/DisLikes Count");
    var responseInfo = json.decode(response.body)['data'];
    responseInfo.forEach((element) {
      postLikes[element['postid']] = element['likes'];
      postDislikes[element['postid']] = element['likes'];
    });
  } catch (error) {
    print(error);
  }
}

void fetchSavedPosts() async {
  var retrieveSavedPost = getDataFromAstra('savedPosts/$currentUserId');
  savedPosts = retrieveSavedPost['data']['savedPosts'];
  print('\nfetchSavedPosts()');
  print(DateTime.now());
}
