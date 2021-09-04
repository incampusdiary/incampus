import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/activity_feed/news_feed.dart';
import 'package:incampusdiary/activity_feed/view_post.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';

class Profile extends StatefulWidget {
  static final id = 'profile';

  final userId;

  Profile({this.userId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final Color white = Colors.white;
    final Color black = Colors.black;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFF6FB1FC),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RotatedBox(
              quarterTurns: 2,
              child: ClipPath(
                clipper: BottomProfileBG(),
                child: Container(
                  width: width,
                  height: height * 0.65,
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                    //   begin: Alignment.centerRight,
                    //   end: Alignment.centerLeft,
                    // ),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 85,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.0,
                          color: Colors.blue[100],
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            currentUser.photoURL,
                          ),
                          fit: BoxFit.contain,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: "Nunito",
                              fontSize: 24,
                              color: white,
                            ),
                          ),
                          Text(
                            'Student, 4th Year, CSE',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: "Nunito",
                              fontSize: 14,
                              color: white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Heritage Institute of Technology',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: "Nunito",
                              fontSize: 17,
                              color: white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () {},
                  child: Center(
                    child: Container(
                      width: width * 0.85,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        boxShadow: kElevationToShadow[1],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: "Nunito",
                            fontSize: 20,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 250),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Posts',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: "Nunito",
                            fontSize: 25,
                            color: black,
                          ),
                        ),
                        RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.arrow_circle_up_rounded,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 150,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("userInfo")
                          .doc(currentUser.uid)
                          .collection("myPosts")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError || !snapshot.hasData)
                          return Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            ),
                          );

                        return ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          children: snapshot.data.docs.map<Widget>((doc) {
                            return MyPostCard(document: doc);
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Saved Posts',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: "Nunito",
                            fontSize: 25,
                            color: black,
                          ),
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          Icons.arrow_circle_up_rounded,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: savedPosts.length,
                      itemBuilder: (context, index) {
                        var savedPostId = savedPosts[index];
                        var isArticle =
                            (savedPostId[savedPostId.length - 1] == 'a')
                                ? true
                                : false;

                        savedPostId =
                            savedPostId.substring(0, savedPostId.length - 2);

                        return SavedPostCard(
                          document: 'post_$savedPostId.jpg',
                          isArticle: isArticle,
                          postId: savedPostId,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SavedPostCard extends StatelessWidget
{
  final document;
  final isArticle;
  final postId;

  SavedPostCard({this.document, this.isArticle, this.postId});

  @override
  Widget build(BuildContext context) {
    return isArticle
        ? Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("images/content-writing.png"),
                ),
              ),
            ),
          )
        : FutureBuilder(
            future: getDownloadUrl(document),
            builder: (context, snapshot) {
              if (snapshot.hasError || !snapshot.hasData)
                return Center(
                  child: Container(
                    width: 90,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                          color: Colors.black.withOpacity(0.4), width: 1,
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                );
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: InkWell(
                  onTap: () async {
                    var postRef = await FirebaseFirestore.instance
                        .collection("posts")
                        .doc(postId)
                        .get();

                    PostModel postData = PostModel();
                    postData.fromJson(postRef);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ViewPost(postFile: postData),
                      ),
                    );
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(snapshot.data),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                          color: Colors.black.withOpacity(0.4), width: 1),
                    ),
                  ),
                ),
              );
            });
  }

  getDownloadUrl(document) async {
    var photo = FirebaseStorage.instance.ref().child(document);
    var url = await photo.getDownloadURL();

    return url;
  }
}

class MyPostCard extends StatefulWidget {
  final document;

  MyPostCard({this.document});

  @override
  _MyPostCardState createState() => _MyPostCardState();
}

class _MyPostCardState extends State<MyPostCard> {
  @override
  Widget build(BuildContext context) {
    //print("MyPosts: ${document['mediaUrl']}");
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onLongPress: () async {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            var ref1 = firestore.collection('posts').doc(widget.document['postId']);

            var ref2 = firestore
                .collection('userInfo')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .collection('myPosts')
                .doc(widget.document['postId']);

            transaction.delete(ref1);
            transaction.delete(ref2);
          }, timeout: Duration(seconds: 10));
        },
        onTap: () async {
          PostModel postFile = PostModel();
          postFile.fromJson(widget.document);

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return ViewPost(postFile: postFile);
            }),
          );

          print('Back to Profile');
          setState(() {});
        },
        child: Container(
          width: 90,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: (widget.document['mediaUrl'] == "")
                  ? AssetImage("images/content-writing.png")
                  : NetworkImage(widget.document['mediaUrl']),
            ),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(color: Colors.black.withOpacity(0.4), width: 1),
          ),
        ),
      ),
    );
  }
}

class BottomProfileBG extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.9, size.height * 0.955);
    path.quadraticBezierTo(
        size.width * 0.96, size.height * 0.95, size.width, size.height * 0.9);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
