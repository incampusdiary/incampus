import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/models/vetometer/vetometer_background.dart';
import 'package:incampusdiary/screens/login_astra.dart';
import 'live_polls_astra.dart';
import 'package:incampusdiary/widgets.dart';
import 'dart:async';
import 'package:incampusdiary/models/vetometer/poll_options_data.dart';
import 'package:http/http.dart' as http;

class VetometerScreen extends StatefulWidget {
  static const id = "/vetometer";

  @override
  _VetometerScreenState createState() => _VetometerScreenState();
}

var _firebase = FirebaseAuth.instance;
var currentUserId = _firebase.currentUser.uid;
var _firestore = FirebaseFirestore.instance;

class _VetometerScreenState extends State<VetometerScreen> {
  @override
  void initState() {
    print('Vetometer Screen initiated');
    super.initState();
    loadInitialData();
  }

  loadInitialData() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await Future.delayed(Duration(seconds: 1));
      Navigator.popAndPushNamed(context, LoginScreen.id,
          arguments: 'Vetometer');
    } else {
      startTime();
      getUserResponse();
    }
  }

  startTime() async {
    var duration = new Duration(seconds: 2);
    return new Timer(duration, route);
  }

  route() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.popAndPushNamed(context, VetometerLivePolls.id);
  }

  @override
  Widget build(BuildContext context) {
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
        child: Stack(
          children: [
            ClipPath(
              clipper: ThemeClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6FB1FC), Color(0xFF38597E)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 72.0, left: 48.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: logoTitle('InCampus', 22.0),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/vetometer-logo.png',
                    height: 60.0,
                    width: 60.0,
                  ),
                  Text(
                    'VetoMeter',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Nunito",
                      fontSize: 45.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void getUserResponse() async {
  print('$currentUserId');
  var attemptedPolls = [];

  print('Fetching user response:');
  // try {
  // var polls = await _firestore
  //     .collection("userPoll")
  //     .doc(currentUserId)
  //     .collection("pollId")
  //     .get();

  final url = '$headerUrl/userPoll';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
        "Content-Type": "application/json"
      },
    );

    print("Get Poll Stats");
    Map attemptedPollsInfo =
        json.decode(response.body)['data']['$currentUserId'];
    attemptedPollsInfo.forEach((key, value) {
      attemptedPolls.add(key);
    });
    print(attemptedPolls);
    initializePollInfo(attemptedPolls, attemptedPollsInfo);
  } catch (e) {
    print('Exception caught in getUserResponse in VetometerScreen: $e');
  }
}

void initializePollInfo(attemptedPolls, attemptedPollsInfo) {
  for (var everyPoll in attemptedPolls)
    listOfAttemptedPolls[everyPoll] =
        attemptedPollsInfo['$everyPoll']["selectedPolls"];

  print(listOfAttemptedPolls);
}

class ThemeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
