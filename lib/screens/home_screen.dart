import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/activity_feed/comments.dart';
import 'package:incampusdiary/activity_feed/news_feed.dart';
import 'package:incampusdiary/main.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:incampusdiary/rounded_button.dart';
import 'package:incampusdiary/services/google.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:incampusdiary/vetometer/vetometer_screen_astra.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final _database = FirebaseFirestore.instance;
  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    print(DateTime.now());
    if(currentUser != null) {
      fetchAlreadyVisitedPosts();
      fetchAllPostLikes();
      fetchAllPostDisLikes();
      fetchSavedPosts();
    }
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       NotificationDetails(
    //         android: AndroidNotificationDetails(
    //           channel.id,
    //           channel.name,
    //           channel.description,
    //           color: Colors.blue,
    //           playSound: true,
    //           icon: '@mipmap/ic_launcher',
    //         ),
    //       ),
    //     );
    //   }
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('\nA new onMessageOpenedApp event was published.');
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     showDialog(
    //         context: context,
    //         builder: (_) {
    //           return AlertDialog(
    //             title: Text(notification.title),
    //             content: SingleChildScrollView(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [Text(notification.body)],
    //               ),
    //             ),
    //           );
    //         });
    //   }
    // });

    // print('\n\nEntered Init state of MessageHandler()');
    // handleFirebaseMessaging();
  }

  // void handleFirebaseMessaging() {
  //   if (Platform.isIOS) {
  //     handleIosPermissions();
  //   } else
  //     _saveDeviceToken();
  //   _fcm.getInitialMessage().then((RemoteMessage remoteMessage) {
  //     if (remoteMessage != null) {
  //       //Todo: Some logic to check whether the user is logged in or not.
  //       //Todo: Redirect to appropriate page.
  //       Navigator.pushNamed(context, NewsFeed.id, arguments: remoteMessage);
  //     }
  //   });
  //   FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
  //     RemoteNotification notification = remoteMessage.notification;
  //     AndroidNotification androidNotification =
  //         remoteMessage.notification?.android;
  //
  //     if (notification != null && androidNotification != null) {
  //       flutterLocalNotificationsPlugin.show(
  //           notification.hashCode,
  //           notification.title,
  //           notification.body,
  //           NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               channel.id,
  //               channel.name,
  //               channel.description,
  //               color: Colors.blue,
  //               playSound: true,
  //               icon: '@mipmap/ic_launcher',
  //             ),
  //           ));
  //     }
  //   });
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
  //     print('A new onMessageOpenedApp event was published!');
  //     Navigator.pushNamed(context, VetometerScreen.id,
  //         arguments: remoteMessage);
  //   });
  // }
  //
  // _saveDeviceToken() async {
  //   String currentUserId = firebase.currentUser.uid;
  //   String fcmToken = await _fcm.getToken();
  //
  //   print('\n\nEntered saveDeviceToken() | $fcmToken');
  //   if (fcmToken != null) {
  //     var tokenRef = _database
  //         .collection('userInfo')
  //         .doc(currentUserId)
  //         .collection('fcmTokens')
  //         .doc(fcmToken);
  //     tokenRef.set({
  //       'token': fcmToken,
  //       'createdAt': Timestamp.now(),
  //       'platform': Platform.operatingSystem
  //     });
  //   }
  // }
  //
  // void handleIosPermissions() {
  //   _fcm.requestPermission();
  //   //Todo: If permission is not available, request for it. If authorized, then call for _saveDeviceToken().
  // }

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
                      // flutterLocalNotificationsPlugin.show(
                      //     0,
                      //     'Testing',
                      //     'body',
                      //     NotificationDetails(
                      //         android: AndroidNotificationDetails(
                      //             channel.id, channel.name, channel.description,
                      //             importance: Importance.high,
                      //             color: Colors.blue,
                      //             playSound: true,
                      //             icon: '@mipmap/ic_launcher')));
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
    // if (alreadyVisitedPosts.containsKey(postModelRef.postId)) {
    //   postsToBeShownLater.add(postModelRef);
    // } else
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
  fetchFirstGetList();

  var db = FirebaseDatabase.instance.reference().child('alreadyVisited');
  var snapshot = await db.child(firebase.currentUser.uid).once();
  alreadyVisitedPosts = snapshot.value ?? {};
  print('printing:\n\n');
  print(alreadyVisitedPosts);
  fetchFirstGetList();
}

void fetchAllPostLikes() async {
  var snapshot =
      await FirebaseDatabase.instance.reference().child('likes').once();
  postLikes = snapshot.value ?? {};
  print('\nfetchAllPostLikes()');
  print(DateTime.now());
}

void fetchAllPostDisLikes() async {
  var snapshot =
      await FirebaseDatabase.instance.reference().child('dislikes').once();
  postDislikes = snapshot.value ?? {};
  print('\nfetchAllPostDisLikes()');
  print(DateTime.now());
}

void fetchSavedPosts() async {
  var retrieveSavedPost =
      await firestore.collection('userInfo').doc(currentUser.uid).get();
  savedPosts = retrieveSavedPost['savedPosts'];
  print('fetchSavedPosts()');
}
