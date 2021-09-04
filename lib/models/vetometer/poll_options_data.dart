import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:incampusdiary/models/vetometer/vetometer_background.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

HashMap<String, List> listOfAttemptedPolls = HashMap();

class PollOptionsData extends ChangeNotifier {
  List<String> pollOptions = [];

  int _countOfSelectedOptions = 0;
  int _selectedLimit = 1;

  List<bool> selectedOptions = [];
  bool isSelectedOptionChange = false;

  bool isAlreadyVisited = false;
  var _firestore = FirebaseFirestore.instance;

  String _pollId;
  String get pollId => _pollId;

  set pollId(pollId) {
    _pollId = pollId;
  }

  /**  Used in Live Polls to mark as visited */
  void notifyPollAttempted() {
    notifyListeners();
  }

  bool isVisited(documentId) {
    if (listOfAttemptedPolls.containsKey(documentId))
      return true;
    else
      return false;
  }

  void viewPollIntializeData() {
    pollOptions = [];
    _countOfSelectedOptions = 0;
    _selectedLimit = 1;
    selectedOptions = [];
    isSelectedOptionChange = false;
  }

  List<bool> get selectedOptionArray => selectedOptions;
  int get countOfSelectedOptions => _countOfSelectedOptions;

  set firstVisit(polls) {
    isAlreadyVisited = false;
    viewPollIntializeData();
    for (var poll in polls) {
      selectedOptions.add(false);
      pollOptions.add(poll);
    }
  }

  void alreadyVisited(List polls, List userResponse) {
    isAlreadyVisited = true;
    viewPollIntializeData();
    print('Printing in already visited: $userResponse');
    for (int i = 0; i < polls.length; i++) {
      pollOptions.add(polls[i]);
      selectedOptions.add(userResponse[i]);
      if (selectedOptions[i]) _countOfSelectedOptions++;
    }
    print('Count of Selected options $_countOfSelectedOptions');
  }

  set selectedOptionsLimit(int limit) {
    _selectedLimit = limit;
  }

  void updatePollOption(int index) {
    print('Updation Started $index');

    if (!selectedOptions[index]) {
      if (_countOfSelectedOptions < _selectedLimit) {
        _countOfSelectedOptions++;
        selectedOptions[index] = true;
        print(selectedOptions);
        isSelectedOptionChange = true;
      } else {
        isSelectedOptionChange = false;
        HapticFeedback.vibrate();
      }
    } else {
      _countOfSelectedOptions--;
      selectedOptions[index] = false;
      isSelectedOptionChange = true;
    }
    notifyListeners();
  }

  updatePollCounter() async {
    try {
      Map temp = handleFirstPolling();
      updatePollCounterAstraDB(temp);
    } catch (e) {
      updatePollCounter();
    }
  }

  handleFirstPolling() {
    print('handleFirstPolling()');
    Map m = {};
    for (int i = 0; i < selectedOptions.length; i++) {
      if (selectedOptions[i]) m['poll$i'] = '+1';
    }
    return m;
  }

  updatePollCounterAstraDB(temp) async {
    final url =
        'https://$ASTRA_DB_ID-$ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/keyspaces/$ASTRA_DB_KEYSPACE/pollCounters/$pollId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
          "Content-Type": "application/json",
        },
        body: json.encode(temp),
      );
      print("Counter Updated");
      print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      print(error);
    }
  }
}
