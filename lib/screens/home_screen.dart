import 'package:flutter/material.dart';
import 'package:incampusdiary/rounded_button.dart';
import 'package:incampusdiary/services/google.dart';
import '../widgets.dart';

class HomeScreen extends StatelessWidget {
  static const id = "home_screen";

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "logo",
                  child: animatedLogoTitle('InCampus Diary_', 40),
                ),
                logoSubtitle(),
                connectNowButton(context),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RoundedButton(
                      title: 'Log Out',
                      onPressed: () {
                        signOutGoogle();
                      }),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
                  child:
                      colorizedAnimatedText('An AtmaNirbhar Bharat Initiative'),
                ),
              ],
            ),
          )),
    );
  }
}
