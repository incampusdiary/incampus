import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/models/vetometer/edit_poll_model.dart';
import 'package:incampusdiary/models/vetometer/vetometer_background.dart';
import 'package:incampusdiary/rounded_button.dart';
import 'package:incampusdiary/models/vetometer/poll_options_data.dart';
import 'poll_stats_astra.dart';
import 'package:provider/provider.dart';
import 'edit_poll_astra.dart';
import 'package:http/http.dart' as http;

class VetometerViewPoll extends StatefulWidget {
  static const id = "vetometer_view_poll";

  @override
  _VetometerViewPollState createState() => _VetometerViewPollState();
}

var _firebase = FirebaseAuth.instance;
var currentUserId = _firebase.currentUser.uid;
var _firestore = FirebaseFirestore.instance;
bool isEdited = false;
List userResponse;

class _VetometerViewPollState extends State<VetometerViewPoll> {
  var document;
  var pollId;
  String linkOfThisPoll;

  @override
  void initState() {
    super.initState();
    isEdited = false;
    print(pollId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map documents = ModalRoute.of(context).settings.arguments as Map;
    document = documents['first'];
    pollId = documents['second'];
    // pollId = document.id;
    print(pollId);
    final providerFalse = Provider.of<PollOptionsData>(context, listen: false);
    final isAlreadyVisited =
        Provider.of<PollOptionsData>(context, listen: false).isAlreadyVisited;

    var kText;
    if (document['responseLimit'] == 1)
      kText = 'You can select ONLY 1 option:';
    else
      kText = 'You can select upto ${document['responseLimit']} options:';

    print('View Poll Entered');
    print(listOfAttemptedPolls);

    bool isEditIconVisible = (document['userId'] == currentUserId ||
        currentUserId == 'admin_in_campus');

    return VetometerBackground(
      lightColor: Colors.green,
      darkColor: Colors.green[900],
      glowColor: Colors.greenAccent[700],
      blinkingAnimation: true,
      headerTitle: "View Poll",
      child: Column(
        children: [
          SizedBox(height: 150.0),

          /* Edit Poll Icon */
          Visibility(
            visible: isEditIconVisible,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: GestureDetector(
                onTap: () async {
                  print("Edit Icon tapped");

                  pollModel.fromJson(document);
                  print('PollModel: ${pollModel.toMap()}');
                  document = await Navigator.pushNamed(
                      context, VetometerEditPoll.id,
                      arguments: {'first': document, 'pollId': pollId});
                  print('Document Received Back: $document');
                  setState(() {});
                  // build(context);
                },
                child: Image.asset(
                  'images/edit_icon.png',
                  height: 45.0,
                  width: 45.0,
                ),
              ),
            ),
          ),

          /* Poll Information */
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: kContainerElevation),
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      document['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Nunito",
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      document['pollDescription'],
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontFamily: "Nunito",
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                kText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 22,
                ),
              ),
            ),
          ),

          /*  Poll Options */
          Padding(
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            child: ViewPollOptions(isAlreadyVisited),
          ),
          SizedBox(height: 40.0),
          RoundedButton(
              title: 'Share',
              onPressed: () {
                // linkOfThisPoll == null || linkOfThisPoll.isEmpty
                //     ? showSnackBar(
                //         'Some error occured. Try again.', Colors.redAccent)
                //     : _onShare(context);
                //   getPollResultFromAstraDB(pollId, providerFalse);
              }),
          SizedBox(height: 100.0),
        ],
      ),

      /*  Vote Button */
      positionedWidget: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: RoundedButton(
          height: 60,
          color: isAlreadyVisited ? Colors.blue[900] : Colors.red,
          title: isAlreadyVisited ? 'View Result' : 'VOTE',
          onPressed: () async {
            print('Button pressed | isAlreadyVisited: $isAlreadyVisited');
            if (!isAlreadyVisited) {
              if (providerFalse.countOfSelectedOptions > 0) {
                savePollDataToAstraDB(providerFalse);
                listOfAttemptedPolls[pollId] =
                    providerFalse.selectedOptionArray;
                Navigator.pop(context);
                providerFalse.notifyPollAttempted();
                providerFalse.updatePollCounter();
              } else
                showSnackBar('Choose atleast 1 option!');
            } else {
              // var countOfEveryPoll = await getPollResult(document);
              var countOfEveryPoll =
                  await getPollResultFromAstraDB(pollId, providerFalse);
              Navigator.pushNamed((context), VetometerPollStats.id,
                  arguments: {'first': document, 'second': countOfEveryPoll});
            }
          },
          minWidth: double.infinity,
          borderRadius: 0,
        ),
      ),
    );
  }

  Future savePollDataToAstraDB(providerFalse) async {
    final url =
        '$headerUrl/userPoll/$currentUserId/$pollId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
          "Content-Type": "application/json"
        },
        body: json.encode(
          {'selectedPolls': providerFalse.selectedOptionArray},
        ),
      );
      print("Poll Response Added");
      print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      print(error);
    }
  }

  showSnackBar(String _snackText, [Color backgroundColor = Colors.black]) {
    final snackBar = SnackBar(
      content: Text(
        _snackText,
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: 2),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class ViewPollOptions extends StatelessWidget {
  final bool isAlreadyVisited;

  ViewPollOptions(this.isAlreadyVisited);

  @override
  Widget build(BuildContext context) {
    showSnackBar(String _snackText) {
      final snackBar = SnackBar(
        content: Text(
          _snackText,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black,
      );
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    final providerFalse = Provider.of<PollOptionsData>(context, listen: false);
    final providerTrue = Provider.of<PollOptionsData>(context);

    print('ListView Builder');
    print(providerTrue.pollOptions.length);

    return ListView.builder(
        itemCount: providerFalse.pollOptions.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final option = providerFalse.pollOptions[index];
          print(option);
          return GestureDetector(
            onTap: () {
              if (!isAlreadyVisited) {
                providerFalse.updatePollOption(index);

                /* countOfSelectedOptions > responseLimit */
                if (!providerFalse.isSelectedOptionChange) {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                      showSnackBar('You CANNOT select more Options!'));
                }
              } else
                showSnackBar('You are not allowed to Re-Vote!');
            },
            child: Container(
              decoration: BoxDecoration(
                  color: providerTrue.selectedOptions[index]
                      ? Colors.lightGreenAccent.shade700.withOpacity(0.65)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: kContainerElevation),
              margin: EdgeInsets.only(top: 16.0),
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Container(
                      margin: EdgeInsets.only(top: 4),
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: providerTrue.selectedOptions[index]
                              ? Colors.black
                              : Colors.transparent,
                        ),
                      )),
                  SizedBox(width: 15),
                  Flexible(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: "Nunito",
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          );
        });
  }
}

Future<List<int>> getPollResult(document) async {
  var ref = await _firestore.collection(document.id).get();
  var counterFiles = ref.docs;
  List<int> countOfEveryPoll = [];
  var totalPolls = 0;
  for (int i = 0; i < document['pollOptions'].length; i++) {
    var count = 0;
    for (var files in counterFiles) {
      try {
        var x = files['option $i'];
        count += x;
      } catch (e) {
        print(e.message);
      }
    }
    totalPolls += count;
    countOfEveryPoll.add(count);
  }
  countOfEveryPoll.add(totalPolls);
  print(countOfEveryPoll);
  return countOfEveryPoll;
}

Future<List<int>> getPollResultFromAstraDB(pollId, providerFalse) async {
  final url = 'https://$ASTRA_DB_ID-$ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/keyspaces/$ASTRA_DB_KEYSPACE/pollCounters/$pollId';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
        "Content-Type": "application/json",
      },
    );
    print("Get Poll Stats");
    print(json.decode(response.body));

    var pollResponseInfo = json.decode(response.body)['data'][0];
    int countPollOptions = providerFalse.pollOptions.length;

    List<int> countOfEveryPoll = [];
    var totalPolls = 0;
    for (int i = 0; i < countPollOptions; i++)
    {
      try {
        if (pollResponseInfo['poll$i'] != null)
        {
          var countValue = pollResponseInfo['poll$i'];
          var count = int.parse('$countValue');
          assert(count is int);
          totalPolls += count;
          countOfEveryPoll.add(count);
        }
        else {
          countOfEveryPoll.add(0);
        }
      } catch (e) {
        print(e);
      }
    }
    countOfEveryPoll.add(totalPolls);
    print('COUNT: $countOfEveryPoll');
    return countOfEveryPoll;
  } catch (error) {
    print(error);
  }
}
