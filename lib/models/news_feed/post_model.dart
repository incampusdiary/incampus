import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String postId;
  String userId;
  String mediaUrl;
  String userPhotoUrl;
  String description;
  String title;
  String tag;
  List comments;
  bool isFullScreen;
  var timestamp;
  var editedTimestamp;

  /// Never use this function during editing of posts.
  Map<String, dynamic> toMap() => {
        'postId': this.postId,
        'userId': this.userId,
        'mediaUrl': this.mediaUrl,
        'userPhotoUrl': this.userPhotoUrl,
        'description': this.description,
        'title': this.title ?? '',
        'tag': this.tag,
        'isFullScreen': this.isFullScreen,
        'timestamp': this.timestamp,
        'editedTimestamp': this.editedTimestamp,
        'comments': [],
      };

  void fromJson(document) {
    this.postId = document['postId'];
    this.userId = document['userId'];
    this.mediaUrl = document['mediaUrl'];
    this.userPhotoUrl = document['userPhotoUrl'];
    this.description = document['description'];
    this.title = document['title'] ?? '';
    this.tag = document['tag'];
    this.timestamp = document['timestamp'];
    this.isFullScreen = document['isFullScreen'];
    // Todo: Uncomment this line when all previous articles are deleted from database:
    //  this.editedTimestamp = document['editedTimestamp'];
    this.comments = document['comments'];
  }
}

class CommentModel {
  String commenterName;
  String commenterId;
  String commenterPhotoUrl;
  String comment;
  String commentId;
  bool edited = false;
  var timestamp;
  var editedTimestamp;

  Map<String, dynamic> toMap() => {
        'comment': this.comment,
        'commenterId': this.commenterId,
        'commentId': this.commentId,
        'commenterName': this.commenterName,
        'commenterPhotoUrl': this.commenterPhotoUrl,
        'edited': this.edited,
        'timestamp': this.timestamp,
        'editedTimestamp': this.editedTimestamp,
      };
  void fromJson(comment) {
    this.commentId = comment['commentId'];
    this.commenterName = comment['commenterName'];
    this.comment = comment['comment'];
    this.commenterPhotoUrl = comment['commenterPhotoUrl'];
    this.commenterId = comment['commenterId'];
    this.edited = comment['edited'];
    this.timestamp = comment['timestamp'];
    this.editedTimestamp = comment['editedTimestamp'];
  }
}

class ReplyModel {
  String replierName;
  String replierId;
  String reply;
  String replyId;
  String replierPhotoUrl;
  bool edited = false;
  var timestamp;
  var editedTimestamp;

  Map<String, dynamic> toMap() => {
        'replierName': this.replierName,
        'edited': this.edited,
        'replierPhotoUrl': this.replierPhotoUrl,
        'replyId': this.replyId,
        'reply': this.reply,
        'replierId': this.replierId,
        'timestamp': Timestamp.now().toString(),
        'editedTimestamp': this.editedTimestamp,
      };
}
