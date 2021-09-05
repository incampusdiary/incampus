import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:incampusdiary/models/vetometer/vetometer_background.dart';
import 'package:incampusdiary/models/vetometer/poll_options_data.dart';
import 'add_poll_astra.dart';
import 'package:incampusdiary/vetometer/view_poll_astra.dart';
import 'package:provider/provider.dart';
import 'package:incampusdiary/constants.dart';
import 'package:http/http.dart' as http;

class VetometerLivePolls extends StatefulWidget {
  static const id = "vetometer_live_polls";

  @override
  _VetometerLivePollsState createState() => _VetometerLivePollsState();
}

class _VetometerLivePollsState extends State<VetometerLivePolls> {
  var _password;
  var isSubmitted;
  List<Map> listOfPolls = [];
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    getPollData();
  }

  @override
  Widget build(BuildContext context) {
    final String redirectedFromScreen =
        ModalRoute.of(context).settings.arguments as String;

    print(
        'Live Polls Build Entered: redirectedFromScreen: $redirectedFromScreen $isDataLoaded  \n$listOfPolls');

    return RefreshIndicator(
      onRefresh: () => getPollData(),
      displacement: 100,
      color: Colors.red,
      child: VetometerBackground(
        headerTitle: "Live Polls",
        blinkingAnimation: true,
        lightColor: Colors.red,
        child: Column(
          children: [
            SizedBox(height: 140.0),
            !isDataLoaded
                ? Center(
                    child: SizedBox(
                    height: 40,
                    child: CircularProgressIndicator(color: Colors.red),
                  ))
                : ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: listOfPolls.map((doc) {
                      var document;
                      var documentId;
                      doc.forEach((key, value) {
                        documentId = key;
                        document = value;
                      });
                      print('\n');
                      return Padding(
                        padding:
                            EdgeInsets.only(left: 32.0, right: 32.0, top: 28.0),
                        child: AnimatedContainer(
                          duration: Duration(seconds: 2),
                          child: InkWell(
                            onTap: () async {
                              print("Card pressed");
                              if (!document['accessibility'] ||
                                  document['userId'] == currentUserId) {
                                await initializeSelectedPollOption(
                                    document, documentId);
                              } else {
                                passwordDialogBoxInput(
                                    context, document, documentId);
                              }
                            },
                            splashColor: Colors.red,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 24),
                              decoration: BoxDecoration(
                                color: Color(0xFF6FB1FC),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: kContainerElevation,
                              ),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                /*  Title of the Card */
                                children: [
                                  Expanded(
                                    child: Text(
                                      document['title'],
                                      style: TextStyle(
                                        fontFamily: "nunito",
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),

                                  /* Marking as Visited : marksVisitedToAlreadyVotedPoll() */
                                  Consumer<PollOptionsData>(
                                      builder: (context, pollData, child) {
                                    return pollData.isVisited(documentId)
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue[900],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.greenAccent,
                                              size: 20,
                                            ),
                                          )
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(right: 6),
                                            child: Container(
                                              height: 6.0,
                                              width: 6.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  boxShadow:
                                                      kContainerElevation),
                                            ),
                                          );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            /// Uncomment this: Case: When no polls in the database
            // Padding(
            //           padding: const EdgeInsets.symmetric(vertical: 100),
            //           child: Center(
            //             child: Text(
            //               "There are no new Polls yet!\nWhy don't you add one?",
            //               style: TextStyle(
            //                   fontSize: 20,
            //                   fontStyle: FontStyle.italic,
            //                   //Todo: Change this color:
            //                   color: Colors.white),
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //         );
            SizedBox(
              height: 30,
            ),
          ],
        ),

        /*  Add New Poll Button  */
        positionedWidget: customFloatingActionButton(),
      ),
    );
  }

  Future<void> getPollData() async {
    print('\ngetData()\n $ASTRA_DB_ID');

    /* GET HTTP REQUEST USING DOC API */
    final url = '$headerUrl/polls?page-size=10';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
          "Content-Type": "application/json"
        },
      );

      print("Get Request");
      var temp = json.decode(response.body)['data'];
      listOfPolls.clear();
      temp?.forEach((key, value) {
        Map m = {key: value};
        listOfPolls.add(m);
      });
    } catch (error) {
      print(error);
    }
    isDataLoaded = true;
    print("getData() | $listOfPolls");
    setState(() {});
  }

  showSnackBar(String _snackText) {
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
      backgroundColor: Colors.red.shade700,
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  initializeSelectedPollOption(document, documentId) async {
    final providerFalse = Provider.of<PollOptionsData>(context, listen: false);
    var userResponse;

    if (listOfAttemptedPolls.containsKey(documentId))
      userResponse = listOfAttemptedPolls[documentId];
    else
      userResponse = null;
    print('Printing in initialization: $userResponse');

    if (userResponse == null) {
      providerFalse.firstVisit = document['pollOptions'];
    } else {
      print(document['pollOptions']);
      print(userResponse);
      providerFalse.alreadyVisited(document['pollOptions'], userResponse);
    }

    providerFalse.selectedOptionsLimit = document['responseLimit'];
    providerFalse.pollId = documentId;

    var deletedPollId = await Navigator.pushNamed(context, VetometerViewPoll.id,
        arguments: {'first': document, 'second': documentId});
    if (deletedPollId != null) {
      setState(() {
        var r = listOfPolls.length;
        listOfPolls.removeWhere((value) => value.containsKey(deletedPollId));
        var s = listOfPolls.length;
        print('\n\ndeletedPollId: $r $s: $deletedPollId');
      });
    }
  }

  /// Opens a dialog box for private polls
  passwordDialogBoxInput(BuildContext context, document, documentId) {
    print("Enter Password Dialog");
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(8, 32, 8, 8),
                  margin: EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
                  width: 320,
                  height: 300.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 45.0),
                      Text(
                        'This poll is password protected',
                        style: TextStyle(
                          fontFamily: "nunito",
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Please enter the password to view this poll',
                        style: TextStyle(
                          fontFamily: "nunito",
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 35.0),
                      Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: TextFormField(
                            onChanged: (value) {
                              _password = value;
                            },
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.done,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value.length > 5) {
                                return "Too long";
                              } else if (value == null || value.isEmpty) {
                                return "Enter password";
                              } else
                                return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Password',
                              hintStyle:
                                  TextStyle(fontSize: 14, letterSpacing: 2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Colors.blue,
                                ),
                              ),
                              contentPadding: EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12.0,
                                  left: 18.0,
                                  right: 18.0),
                            ),
                          )),
                      SizedBox(height: 15),
                      Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /*  Cancel Button  */
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: Colors.red.withOpacity(0.8),
                                  ),
                                  child: MaterialButton(
                                    height: 0,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                width: 20,
                              ),

                              /*  OK Button  */
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: Colors.blue.withOpacity(0.8),
                                  ),
                                  child: MaterialButton(
                                    height: 0,
                                    onPressed: () async {
                                      if (_password == document['password']) {
                                        Navigator.pop(context);
                                        await initializeSelectedPollOption(
                                            document, documentId);
                                      } else {
                                        Fluttertoast.cancel();
                                        Fluttertoast.showToast(
                                            msg: 'Wrong Password',
                                            backgroundColor: Colors.black87,
                                            textColor: Colors.redAccent,
                                            gravity: ToastGravity.CENTER,
                                            fontSize: 18);
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'images/password_lock_blue.png',
                    height: 90.0,
                    width: 90.0,
                  ),
                ),
              ],
            ),
          );
        });
  }

  /*  Navigates to AddPoll Screen  */
  Widget customFloatingActionButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(right: 16.0, bottom: 32.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: kContainerElevation,
            ),
            child: Image.asset(
              'images/button.png',
              height: 60.0,
              width: 60.0,
            ),
          ),
        ),
        onTap: () {
          //Todo: use popUntil instead of pushNamed
          Navigator.pushNamed(context, VetometerAddPoll.id);
        },
      ),
    );
  }
}
