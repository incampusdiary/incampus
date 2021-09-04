import 'package:flutter/cupertino.dart';

class TestingModel extends ChangeNotifier{
  int _count = 0;

  get countValue => _count;
  void setCountValue() {
    _count++;
    notifyListeners();
  }
}