import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:incampusdiary/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'news_feed.dart';

class Comments extends StatefulWidget {
  @override
  _CommentsState createState() => _CommentsState();
}

//Todo: Call editReply with abort true if editing is in progress and the comment screen is dragged down.
var currentUser = firebase.currentUser;
final String _redundantCommentId = 'redundantCommentId';
final String _editingInProgressText = 'Editing In Progress...';
bool hasCommentsBeenAdded = false;
bool hasCommentsBeenDeleted = false;
bool hasCommentsBeenEdited = false;
List addedComments = [];
List deletedComments = [];

class _CommentsState extends State<Comments> {
  final focusNode = FocusNode();
  final commentController = TextEditingController();
  Map repliesLength;

  /// Stores the number of replies on all comments of this post.

  @override
  void initState() {
    super.initState();
    getNumberOfRepliesOnComments();
  }

  void getNumberOfRepliesOnComments() async {
    print('getNumberOfRepliesOnComments() | Started');
    var data = await database.child('repliesLength').child(post.postId).get();
    repliesLength = data.value ?? {};
    print('getNumberOfRepliesOnComments() | Exited $repliesLength');
    sortComments(post.comments);
  }

  void sortComments(List commentsList) async {
    print('sortComments() | $repliesLength');
    int i = 0;
    if (repliesLength != null && repliesLength.isNotEmpty)
      commentsList.sort((a, b) {
        print(Timestamp.now());
        print('\n${i++}');
        print(
            'No. of replies: ${repliesLength[a[_redundantCommentId]['commentId']]}');
        print(
            'No. of replies: ${repliesLength[b[_redundantCommentId]['commentId']]}');
        return (repliesLength[a[_redundantCommentId]['commentId']] ?? 0) -
            (repliesLength[b[_redundantCommentId]['commentId']] ?? 0);
      });
    setState(() {});
  }

  @override
  void dispose() {
    // repliesLength.clear();
    print('\n\nComments disposed called');
    isEditingCommentInProgress ? abortCurrentEditingOfComment() : null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List commentsList = post.comments;
    print('\n\nComments List: $commentsList');

    // replies =
    //     database.child('replies').child(post.postId).onValue.listen((event) {});
    // print('\n\nFetching replies: \n${replies.data}');
    // print('Showing commments: \n${commentsList[0]}');
    return DraggableScrollableSheet(
      minChildSize: 0.25,
      initialChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Material(
          elevation: 20,
          color: Colors.black.withOpacity(0.8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                /// Comments Header
                SizedBox(height: 50),
                Text(
                  'Comments(${commentsList.length})',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6FB1FC),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(85, 0, 200, 0),
                  child: Divider(
                    color: Colors.white,
                    thickness: 2,
                  ),
                ),
                SizedBox(height: 40),

                ///  Comment TextField
                Padding(
                  padding: EdgeInsets.only(left: 4, right: 4, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          FirebaseAuth.instance.currentUser.photoURL,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.left,
                          maxLines: 4,
                          minLines: 1,
                          controller: commentController,
                          focusNode: focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          maxLengthEnforcement: MaxLengthEnforcement.none,
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(12),
                              child: InkWell(
                                onTap: () {
                                  print('\nSend icon tapped');
                                  if (commentController.text.trim() ==
                                      _editingInProgressText) {
                                    showToast(
                                        message: 'Ho gaya?\nAa gaya swad!? :-p',
                                        color: Colors.pink);
                                    return;
                                  }
                                  if (commentController.text != null &&
                                      commentController.text.isNotEmpty) {
                                    isEditingCommentInProgress
                                        ? editComment(commentsList[editedIndex]
                                            [_redundantCommentId])
                                        : addNewComment(commentsList);
                                    focusNode.unfocus();
                                  } else
                                    showToast(
                                        color: Colors.yellow,
                                        message: 'Not a valid comment!');
                                },
                                child: SvgPicture.asset(
                                  'images/send.svg',
                                  width: 5,
                                  height: 5,
                                ),
                              ),
                            ),
                            contentPadding: EdgeInsets.only(top: 15, left: 10),
                            hintText: "Add your public comment..",
                            hintStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.75),
                            ),
                            enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Comment List
                SingleChildScrollView(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(0),
                    reverse: true,
                    itemCount: commentsList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(
                            '${commentsList[index][_redundantCommentId]['commentId']} ${commentsList[index][_redundantCommentId]['comment']}'),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            return await showDialog(
                                context: context,
                                builder: (context) => showDialogue(context));
                          } else {
                            if (currentUser.uid ==
                                commentsList[index][_redundantCommentId]
                                    ['commenterId']) {
                              print('User Authorized');
                              handlingEditCommentInitiation(
                                  commentsList[index][_redundantCommentId]);
                              editedIndex = index;
                              focusNode.requestFocus();
                            }
                            return false;
                          }
                        },
                        onDismissed: (direction) {
                          print('onDismissed called: $direction');
                          setState(() {
                            if (currentUser.uid ==
                                commentsList[index][_redundantCommentId]
                                    ['commenterId']) {
                              print('User Authorized');
                              if (direction == DismissDirection.startToEnd) {
                                print('Deleting index: $index');
                                deleteComment(index);
                              }
                            } else
                              showToast(
                                  message:
                                      'You can only edit/delete your comments');
                          });
                        },
                        background: slideRightBackground(),
                        secondaryBackground: slideLeftBackground(),
                        child: CommentList(
                            comment: post.comments[index], index: index),
                      );
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Holds the entire comment object which is being edited or was edited last.
  var lastEditedComment;

  /// Keeps track of the event that whether a comment is being currently edited
  /// or not.
  bool isEditingCommentInProgress = false;

  /// Holds the value of the comment which is being edited, or was last edited
  /// if nothing is being edited currently.
  String originalComment;

  /// Keeps track of the index of the comment that is being currently edited, or
  /// was last edited if nothing is being currently edited.
  int editedIndex;

  addNewComment(commentsList) {
    CommentModel commentModel = CommentModel();
    commentModel.comment = commentController.text;
    commentController.clear();
    commentModel.commentId = Uuid().v4();
    commentModel.commenterName = FirebaseAuth.instance.currentUser.displayName;
    commentModel.commenterId = firebase.currentUser.uid;
    commentModel.commenterPhotoUrl = FirebaseAuth.instance.currentUser.photoURL;
    commentModel.timestamp = Timestamp.now();
    setState(() {
      commentsList.add({_redundantCommentId: commentModel.toMap()});
      addedComments.add({_redundantCommentId: commentModel.toMap()});
      print('\nAfter Adding:\n${post.comments.length} ${commentModel.toMap()}');
    });
    hasCommentsBeenAdded = true;
  }

  deleteComment(index) {
    print(
        'Entered Delete comment: Editing: $isEditingCommentInProgress  Index: $index');
    if (isEditingCommentInProgress && index == editedIndex) {
      commentController.clear();
      post.comments[index][_redundantCommentId]['comment'] = originalComment;
      isEditingCommentInProgress = false;
      print(isEditingCommentInProgress);
    } else if ((editedIndex ?? -1) > index) editedIndex--;
    setState(() {
      deletedComments.add(post.comments[index]);
      post.comments.removeAt(index);
    });
    print('Deleted Array: $deletedComments \n ${deletedComments.last}');
    hasCommentsBeenDeleted = true;
    // try {
    //   print('Deleting $deletedComment');
    //   firestore.collection('posts').doc(post.postId).set(
    //     {
    //       'comments': FieldValue.arrayRemove([deletedComment]),
    //     },
    //     SetOptions(merge: true),
    //   );
    // } catch (e) {
    //   print('Error Occured: $e');
    // }
  }

  handlingEditCommentInitiation(comment) {
    print(
        '\nhandling Comment initiated: $originalComment  ${comment['comment']}');
    if (lastEditedComment == comment && isEditingCommentInProgress) return;

    if (isEditingCommentInProgress) abortCurrentEditingOfComment();

    lastEditedComment = comment;
    setState(() {
      commentController.text = originalComment = comment['comment'];
      comment['comment'] = _editingInProgressText;
      isEditingCommentInProgress = true;
      print('\nhandling Comment exited:  $originalComment');
    });
  }

  editComment(comment) {
    if (commentController.text.trim() == originalComment)
      return abortCurrentEditingOfComment();
    comment['comment'] = originalComment;
    // print('Deleted Comments Before: $deletedComments');
    deletedComments.add({_redundantCommentId: comment});
    // print('Deleted Comments After: $deletedComments');

    CommentModel temp = CommentModel();
    temp.fromJson(comment);
    temp.edited = true;
    temp.comment = commentController.text.trim();
    temp.editedTimestamp = Timestamp.now();

    setState(() {
      post.comments.add({_redundantCommentId: temp.toMap()});
      post.comments.removeAt(editedIndex);
    });

    addedComments.add({_redundantCommentId: temp.toMap()});
    hasCommentsBeenEdited = true;
    print('Deleted Comments: $deletedComments');
    print('Added comments: $addedComments');
    commentController.clear();
    isEditingCommentInProgress = false;
    print("Exiting editReply:  $originalComment  $isEditingCommentInProgress");
  }

  abortCurrentEditingOfComment([bool closingComments = false]) {
    print('_Comments | abortCurrentEditingOfComment()');

    // setState(() {
    lastEditedComment['comment'] = originalComment;
    // });
    commentController.clear();
    isEditingCommentInProgress = false;
  }

  // showDialogue() {
  //   return AlertDialog(
  //     backgroundColor: Colors.white,
  //     title: Text(
  //       'Confirm',
  //       style: kTitleTextStyle,
  //     ),
  //     content: Text(
  //       'This message will be permanently deleted.\n\nAre you sure?',
  //       style: TextStyle(fontSize: 18, color: Colors.deepPurple),
  //     ),
  //     contentPadding: EdgeInsets.only(top: 12, left: 24, right: 20, bottom: 0),
  //     actions: [
  //       TextButton(
  //           style: TextButton.styleFrom(
  //             elevation: 15,
  //             backgroundColor: Colors.deepPurple.withOpacity(0.6),
  //           ),
  //           onPressed: () {
  //             Navigator.pop(context, true);
  //           },
  //           child: Text(
  //             'Yes',
  //             style: TextStyle(
  //                 fontSize: 22, color: Colors.red, fontWeight: FontWeight.w900),
  //           )),
  //       SizedBox(width: 10),
  //       TextButton(
  //           style: TextButton.styleFrom(
  //             elevation: 15,
  //             backgroundColor: Colors.deepPurple.withOpacity(0.6),
  //           ),
  //           onPressed: () {
  //             Navigator.pop(context, false);
  //           },
  //           child: Text(
  //             'No',
  //             style: TextStyle(
  //                 fontSize: 22,
  //                 color: Colors.blue,
  //                 fontWeight: FontWeight.w900),
  //           )),
  //     ],
  //   );
  // }

  Widget slideRightBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(width: 5),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            SizedBox(width: 20),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}

class CommentList extends StatefulWidget {
  final comment;
  final int index;

  const CommentList({this.comment, this.index});

  @override
  _CommentListState createState() =>
      _CommentListState(comments: comment, index: index);
}

class _CommentListState extends State<CommentList> with WidgetsBindingObserver {
  final Map comments;
  final int index;
  final replyController = TextEditingController();

  final FocusNode inputNode = FocusNode();

  _CommentListState({this.comments, this.index});

  bool openReplies = false;
  bool isEditingReplyInProgress = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    final isBackground = state == AppLifecycleState.paused;
    print('isBackground: $isBackground');

    if (isBackground && isEditingReplyInProgress) {
      abortCurrentEditingOfReply();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build called of _CommentListState');
    print(timeago.format(DateTime.now()));
    final String commentId = comments[_redundantCommentId]['commentId'];
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      highlightColor: Colors.transparent,
      splashColor: Colors.white.withOpacity(0.2),
      onTap: () {
        print('Tapping comment container: 223: openReplies: $openReplies');
        setState(() {
          openReplies = !openReplies;
        });
      },
      child: Column(
        children: [
          /// Comment Container
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 8, 0),
            margin: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Color(0xFF6FB1FC).withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      comments[_redundantCommentId]['commenterPhotoUrl']),
                  radius: 20,
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header of the comment card: Row [Name, edited tag]
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          comments[_redundantCommentId]['commenterName'],
                          style: TextStyle(
                            color: Color(0xFF6FB1FC),
                            fontFamily: "Nunito",
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10),
                        comments[_redundantCommentId]['edited']
                            ? Text(
                                '(Edited ${timeAgoSinceDate(comments[_redundantCommentId]['editedTimestamp']?.toDate().toString())})',
                                style: kSubtitleTextStyle,
                              )
                            : SizedBox(),
                      ],
                    ),
                    SizedBox(height: 5),

                    // Commment Text
                    Text(
                      comments[_redundantCommentId]['comment'],
                      style: TextStyle(
                        color: (_editingInProgressText ==
                                comments[_redundantCommentId]['comment'])
                            ? Colors.grey
                            : Colors.white,
                        fontFamily: "Nunito",
                        fontSize: 17.0,
                        fontWeight: FontWeight.w300,
                        fontStyle: (_editingInProgressText ==
                                comments[_redundantCommentId]['comment'])
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    // Row [Time of Comment, No. of replies]
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeAgoSinceDate(comments[_redundantCommentId]
                                    ['timestamp']
                                .toDate()
                                .toString()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.reply_all,
                            size: 14,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 5),
                          StreamBuilder(
                              stream: database
                                  .child(
                                      'replies') //Todo: Think of using [repliesLength] instead of [replies]
                                  .child(post.postId)
                                  .child(commentId)
                                  .onValue,
                              builder: (context, snapshot) {
                                if (snapshot.hasError || !snapshot.hasData)
                                  return LiquidCircularProgressIndicator();
                                return Text(
                                  (snapshot.data.snapshot.value?.length ?? 0) !=
                                          0
                                      ? 'Replies (${snapshot.data.snapshot.value?.length})'
                                      : 'Wanna Live chat?',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Reply ListView and Reply TextBox Containers
          Visibility(
            visible: openReplies,
            child: Column(
              children: [
                /// Reply TextField : Adding a new reply
                Container(
                  padding: EdgeInsets.fromLTRB(16, 4, 0, 0),
                  margin: EdgeInsets.fromLTRB(24, 0, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.network(
                          FirebaseAuth.instance.currentUser.photoURL,
                          width: 30,
                          height: 30,
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: TextField(
                          controller: replyController,
                          textAlign: TextAlign.left,
                          maxLines: 4,
                          minLines: 1,
                          focusNode: inputNode,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'nunito'),
                          maxLengthEnforcement: MaxLengthEnforcement.none,
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(15),
                              child: InkWell(
                                onTap: () {
                                  if (replyController.text != null &&
                                      replyController.text.isNotEmpty) {
                                    print('Tapped enter arrow');
                                    isEditingReplyInProgress
                                        ? editReply(commentId, index)
                                        : addNewReply(
                                            replyController, commentId);
                                    inputNode.unfocus();
                                    print('Finished addNewReply()');
                                  }
                                },
                                child: SvgPicture.asset(
                                  'images/send.svg',
                                  height: 5,
                                  width: 5,
                                ),
                              ),
                            ),
                            contentPadding: EdgeInsets.only(left: 10, top: 15),
                            hintText: "Add a public reply..",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Color(0xFF6FB1FC).withOpacity(0.25),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Reply List builder
                SingleChildScrollView(
                  child: StreamBuilder(
                      stream: database
                          .child('replies')
                          .child(post.postId)
                          .child(commentId)
                          .onValue,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.hasError)
                          return LiquidCircularProgressIndicator();
                        Map data = snapshot.data.snapshot.value;
                        List replies = [];
                        data?.forEach((key, value) {
                          replies.add(value);
                        });
                        replies.sort((a, b) {
                          int time1 =
                              int.parse(a['timestamp'].substring(18, 28));
                          int time2 =
                              int.parse(b['timestamp'].substring(18, 28));
                          return time1 - time2;
                        });
                        int numberOfReplies = data?.length ?? 0;
                        print('\n\nInside Stream Builder: $numberOfReplies');
                        try {
                          return ListView.builder(
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            itemCount: numberOfReplies,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Dismissible(
                                  key: Key(replies[index]['replyId']),
                                  direction: DismissDirection.horizontal,
                                  confirmDismiss: (direction) async {
                                    if (isEditingReplyInProgress &&
                                        replies[index]['replyId'] ==
                                            editedReplyId) return false;
                                    //Todo: Add admin access condition
                                    if (currentUser.uid ==
                                        replies[index]['replierId']) {
                                      if (direction ==
                                          DismissDirection.startToEnd) {
                                        return await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              showDialogue(context),
                                        );
                                      } else {
                                        handlingEditReplyInitiation(
                                            replies, commentId, index);
                                        return false;
                                      }
                                    } else {
                                      showToast(
                                          message:
                                              'You can only edit/delete your replies');
                                      return false;
                                    }
                                  },
                                  onDismissed: (direction) {
                                    print('Entered onDismissed: $direction');
                                    setState(() {
                                      if (direction ==
                                          DismissDirection.startToEnd) {
                                        print('Authorized to delete');
                                        // if (currentUser.uid ==
                                        //     replies[index]['replierId']) {
                                        deleteReply(commentId,
                                            replies[index]['replyId']);
                                        // } else
                                        //   showToast(
                                        //       message:
                                        //           'You can only edit/delete your replies');
                                      }
                                    });
                                  },
                                  background: slideRightBackground(),
                                  secondaryBackground: slideLeftBackground(),
                                  child: ReplyList(
                                      replies: replies, index: index));
                            },
                          );
                        } catch (e) {
                          print('\n\nException Caught : $e');
                          return SizedBox(height: 0, width: 0);
                        }
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// When the reply/comment containers are slided right, this background is
  /// shown before deleting it.
  Widget slideRightBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  /// When the reply/comment containers are slided left, this background is
  /// shown before initiating editing.
  Widget slideLeftBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(width: 5),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            SizedBox(width: 20),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  String originalReply;
  String editedReplyId;
  String editedCommentId;

  /// Holds the original reply because if a reply is deleted by another user
  /// while abortCurrentEditing is executing, then the index will change.
  String originalReplyCopy;

  /// Holds the original replyId because if a reply is deleted by another user
  /// while abortCurrentEditing is executing, then the index will change.
  String editedReplyIdCopy;

  void handlingEditReplyInitiation(
      List replies, String commentId, int index) async {
    print('handlingEditing initiated: index: $index $isEditingReplyInProgress');

    // Ensuring that data is not lost due to changes from other users
    originalReplyCopy = replies[index]['reply'];
    editedReplyIdCopy = replies[index]['replyId'];

    if (isEditingReplyInProgress) await abortCurrentEditingOfReply();

    try {
      editedReplyId = editedReplyIdCopy;
      editedCommentId = commentId;
      replyController.text = originalReply = originalReplyCopy;
      await database
          .child('replies')
          .child(post.postId)
          .child(commentId)
          .child(editedReplyId)
          .child('reply')
          .set(_editingInProgressText);
      FocusScope.of(context).requestFocus(inputNode);
      isEditingReplyInProgress = true;
      print('original reply: ${replies[index]}');
    } catch (e) {
      print(
          'Exception Caught | _CommentsList | handlingEditReplyInitiation() $e');
      showToast(message: 'An error occured.\nCheck your network!');
    }
  }

  addNewReply(replyController, String commentId) async {
    ReplyModel replyModel = ReplyModel();
    replyModel.reply = replyController.text.trim();
    replyController.clear();
    replyModel.replierName = FirebaseAuth.instance.currentUser.displayName;
    replyModel.replierId = currentUser.uid;
    replyModel.replierPhotoUrl = FirebaseAuth.instance.currentUser.photoURL;
    replyModel.replyId = Uuid().v4();

    bool isNotAdded = true, isNotIncremented = true;
    while (isNotIncremented) {
      try {
        if (isNotAdded) {
          await database
              .child('replies')
              .child(post.postId)
              .child(commentId)
              .child(replyModel.replyId)
              .set(replyModel.toMap());
          isNotAdded = false;
        }
        if (isNotIncremented) {
          await database
              .child('repliesLength')
              .child(post.postId)
              .child(commentId)
              .set(ServerValue.increment(1));
          isNotIncremented = false;
        }
        print('New Reply Added : ${replyModel.toMap()}');
      } catch (e) {
        print('Exception Caught | _CommentsList | addNewReply() $e');
        showToast(message: 'An error occured.\nCheck your network!');
      }
    }
  }

  deleteReply(String commentId, String replyId) async {
    if (isEditingReplyInProgress && editedReplyId == replyId) {
      replyController.clear();
      isEditingReplyInProgress = false;
      inputNode.unfocus();
    }

    print('Deleting from database: ');

    bool isNotDeleted = true, isNotDecremented = true;
    while (isNotDecremented) {
      try {
        if (isNotDeleted) {
          await database
              .child('replies')
              .child(post.postId)
              .child(commentId)
              .child(replyId)
              .remove();
          isNotDeleted = false;
        }
        if (isNotDecremented) {
          await database
              .child('repliesLength')
              .child(post.postId)
              .child(commentId)
              .set(ServerValue.increment(-1));
          isNotDecremented = false;
        }
      } catch (e) {
        print('Exception Caught | deleteReply() | $e');
      }
    }
    print('Deleted from firestore');
  }

  editReply(String commentId, int index) async {
    isEditingReplyInProgress = false;
    print('Entering edit reply with index: $index');
    try {
      await database
          .child('replies')
          .child(post.postId)
          .child(commentId)
          .child(editedReplyId)
        ..child('reply').set(replyController.text.trim())
        ..child('edited').set(true)
        ..child('editedTimestamp').set(Timestamp.now().toString());
      replyController.clear();
      print('Editing done | _CommentsList | editReply()');
    } catch (e) {
      print(
          '\nException Caught | _CommentsList | handlingEditReplyInitiation() $e');
      showToast(message: 'An error occured.\nCheck your network!');
    }
  }

  abortCurrentEditingOfReply() async {
    print('\nNo saving needed: $originalReply');
    try {
      await database
          .child('replies')
          .child(post.postId)
          .child(editedCommentId)
          .child(editedReplyId)
          .child('reply')
          .set(originalReply);
    } catch (e) {
      print(
          '\nException Caught | _CommentsList | handlingEditReplyInitiation() $e');
      showToast(message: 'An error occured.\nCheck your network!');
    }
  }

  // showDialogue() {
  //   return AlertDialog(
  //     backgroundColor: Colors.white,
  //     title: Text(
  //       'Confirm',
  //       style: kTitleTextStyle,
  //     ),
  //     content: Text(
  //       'This message will be permanently deleted.\n\nAre you sure?',
  //       style: TextStyle(fontSize: 18, color: Colors.deepPurple),
  //     ),
  //     contentPadding: EdgeInsets.only(top: 12, left: 24, right: 20, bottom: 0),
  //     actions: [
  //       TextButton(
  //           style: TextButton.styleFrom(
  //             elevation: 15,
  //             backgroundColor: Colors.deepPurple.withOpacity(0.6),
  //           ),
  //           onPressed: () {
  //             Navigator.pop(context, true);
  //           },
  //           child: Text(
  //             'Yes',
  //             style: TextStyle(
  //                 fontSize: 22, color: Colors.red, fontWeight: FontWeight.w900),
  //           )),
  //       SizedBox(width: 10),
  //       TextButton(
  //           style: TextButton.styleFrom(
  //             elevation: 15,
  //             backgroundColor: Colors.deepPurple.withOpacity(0.6),
  //           ),
  //           onPressed: () {
  //             Navigator.pop(context, false);
  //           },
  //           child: Text(
  //             'No',
  //             style: TextStyle(
  //                 fontSize: 22,
  //                 color: Colors.blue,
  //                 fontWeight: FontWeight.w900),
  //           )),
  //     ],
  //   );
  // }

  static String timeAgoSinceDate(String dateString,
      {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 year ago' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} months ago';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 month ago' : 'Last month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}

class ReplyList extends StatelessWidget {
  final List replies;
  final int index;

  ReplyList({this.replies, this.index});
  @override
  Widget build(BuildContext context) {
    print('Entered ReplyList build @ ${replies[index]['timestamp']}');
    int length = replies[index]['timestamp'].toString().length;
    int _seconds = int.parse(replies[index]['timestamp'].substring(18, 28));
    int _nanoseconds =
        int.parse(replies[index]['timestamp'].substring(42, length - 1));
    print('$_seconds   $_nanoseconds');
    Timestamp timestamp = Timestamp(_seconds, _nanoseconds);

    ///  Reply Cards
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: EdgeInsets.fromLTRB(36, 0, 0, 6),
      decoration: BoxDecoration(
        color: Color(0xFF6FB1FC).withOpacity(0.25),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(replies[index]['replierPhotoUrl']),
            radius: 15,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header of the reply card: Contains replier name and 'edited' tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      replies[index]['replierName'],
                      style: TextStyle(
                        color: Color(0xFF6FB1FC),
                        fontFamily: "Nunito",
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 10),
                    replies[index]['edited']
                        ? Text(
                            '(Edited)',
                            style: kSubtitleTextStyle,
                          )
                        : SizedBox(),
                  ],
                ),
                SizedBox(height: 8),
                // Reply text
                Text(
                  replies[index]['reply'],
                  style: TextStyle(
                    fontStyle: replies[index]['reply'] == _editingInProgressText
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: replies[index]['reply'] == _editingInProgressText
                        ? Colors.grey
                        : Colors.white,
                    fontFamily: "Nunito",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 4),
                Text(
                  timeAgoSinceDate(timestamp?.toDate().toString()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    // print('ReplyList | timeAgoSinceDate() | date: $date');
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 year ago' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} months ago';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 month ago' : 'Last month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}

class CommentDesign extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 20);
    path.quadraticBezierTo(-5, size.height, 20.0, size.height);
    path.lineTo(size.width - 20.0, size.height);
    path.quadraticBezierTo(
        size.width + 5, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 20.0);
    path.quadraticBezierTo(size.width, -5.0, size.width - 20.0, 0.0);
    path.lineTo(20.0, 0.0);
    path.quadraticBezierTo(0.0, 0.0, 0.0, 20.0);
    return path;
    // var path = Path();
    // path.lineTo(10, 0);
    // path.quadraticBezierTo(-5, 0, 10, 10);
    // path.lineTo(10, 20);
    // path.lineTo(10, size.height - 20);
    // path.quadraticBezierTo(0.0, size.height, 20.0, size.height);
    //
    // path.close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

//Todo: Add  a condition: if(currentUser.uid == '$idOfInCampus') edition & delete all comments and replies.
