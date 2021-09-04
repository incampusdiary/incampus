import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/activity_feed/comments.dart';
import 'package:incampusdiary/activity_feed/profile.dart';
import 'package:incampusdiary/constants.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:incampusdiary/rounded_button.dart';
import 'package:flutter_svg/svg.dart';
import 'news_feed.dart';

var firestore = FirebaseFirestore.instance;

//Todo: Add more space after paragraph

class PostDescription extends StatelessWidget {

  static final id = 'post_description';
  final firebase = FirebaseAuth.instance.currentUser;

  final PostModel postFile;
  PostDescription({@required this.postFile});

  @override
  Widget build(BuildContext context) {
    print('Showing Post Description Screen');
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16.0, right: 16, bottom: 32, top: 96),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*  Intro of the poster  */
            (currentUser.uid == postFile.userId)
                ? Container()
                : Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /*  Profile pic of the poster  */
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Profile(userId: postFile.userId),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: kContainerElevation),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                postFile.userPhotoUrl,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Text(
                            firebase.displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        Text(
                          'Student IT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 10),
            /*  Description of the postFile */
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Caption',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(
                        postFile.mediaUrl != ''
                            ? postFile.description
                            : 'Please Like and Share this Article',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            /*  Like and Comments counters  */
            Row(
              children: [
                /*   Like Icon   */
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'images/likes.svg',
                        height: 100,
                      ),
                      // SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          StreamBuilder(
                              stream: database
                                  .child('likes')
                                  .child(postFile.postId)
                                  .onValue,
                              builder: (context, snapshot) {
                                print(snapshot.data);
                                if (!snapshot.hasData || snapshot.hasError)
                                  return CircularProgressIndicator();
                                return Text(
                                  snapshot.data.snapshot.value?.toString() ??
                                      '0',
                                  style: TextStyle(
                                      // textBaseline: TextBaseline.ideographic,
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                );
                              }),
                          Text(
                            'people like this post',
                            style: TextStyle(
                                // textBaseline: TextBaseline.ideographic,
                                fontSize: 12,
                                color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /*   Comments Icon  */
                Expanded(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'images/comments.svg',
                        height: 90,
                        width: 100,
                        allowDrawingOutsideViewBox: false,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('12',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900)),
                          Text(
                            'comments on this post',
                            style: TextStyle(
                                // textBaseline: TextBaseline.alphabetic,
                                fontSize: 12,
                                color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:incampusdiary/constants.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_svg/svg.dart';
// import '../models/news_feed/news_feed_data_model.dart';
// import 'news_feed.dart';
//
// var firestore = FirebaseFirestore.instance;
//
// //Todo: Add more space after paragraph
//
// class PostDescription extends StatelessWidget {
//   static final id = 'post_description';
//
//   final firebase = FirebaseAuth.instance.currentUser;
//   @override
//   Widget build(BuildContext context) {
//     final providerFalse = Provider.of<NewsFeedData>(context, listen: false);
//     return Material(
//       type: MaterialType.transparency,
//       child: Stack(
//         children: [
//           Opacity(
//             opacity: 0.6,
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.black,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//                 left: 16.0, right: 16, bottom: 72, top: 96),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         margin: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             boxShadow: kContainerElevation),
//                         child: CircleAvatar(
//                           radius: 50,
//                           backgroundImage: NetworkImage(
//                             postFile.userPhotoUrl,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 8, top: 4),
//                         child: Text(
//                           firebase.displayName,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                       ),
//                       Text(
//                         'Student IT',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             color: Colors.blue,
//                             fontWeight: FontWeight.w900,
//                             fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Expanded(
//                   flex: 2,
//                   child: Center(
//                     child: SingleChildScrollView(
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.white70,
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                         child: Text(
//                           postFile.description,
//                           style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w400),
//                           textAlign: TextAlign.justify,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SvgPicture.asset(
//                             'images/likes.svg',
//                             height: 100,
//                           ),
//                           // SizedBox(height: 12),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.baseline,
//                             textBaseline: TextBaseline.alphabetic,
//                             children: [
//                               Text(
//                                 '51',
//                                 style: TextStyle(
//                                     // textBaseline: TextBaseline.ideographic,
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w900),
//                               ),
//                               Text(
//                                 'people like this post',
//                                 style: TextStyle(
//                                     // textBaseline: TextBaseline.ideographic,
//                                     fontSize: 12,
//                                     color: Colors.white70),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: Column(
//                         children: [
//                           SvgPicture.asset(
//                             'images/comments.svg',
//                             height: 90,
//                             width: 100,
//                             allowDrawingOutsideViewBox: false,
//                             fit: BoxFit.fill,
//                           ),
//                           SizedBox(height: 5),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.baseline,
//                             textBaseline: TextBaseline.alphabetic,
//                             children: [
//                               Text('12',
//                                   style: TextStyle(
//                                       fontSize: 20,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w900)),
//                               Text(
//                                 'comments on this post',
//                                 style: TextStyle(
//                                     // textBaseline: TextBaseline.alphabetic,
//                                     fontSize: 12,
//                                     color: Colors.white70),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
