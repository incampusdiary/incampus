import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:incampusdiary/activity_feed/news_feed.dart';

class NewsFeedData extends ChangeNotifier {
  bool _speedDialVisibility = true;

  var commentsList = post.comments;
  bool get speedDialVisibility => _speedDialVisibility;

  toggleSpeedDialVisibility() {
    _speedDialVisibility = !_speedDialVisibility;
    notifyListeners();
  }
}
