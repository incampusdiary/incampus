import 'package:firebase_auth/firebase_auth.dart';
import 'package:incampusdiary/vetometer/vetometer_screen_astra.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

Widget logoTitle(String text, double size) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: "ElMessiri",
      fontWeight: FontWeight.w700,
      fontSize: size,
      color: Colors.white,
    ),
  );
}

Widget animatedLogoTitle(String text, double size) {
  return TypewriterAnimatedTextKit(
    text: ['InCampus Diary'],
    textStyle: TextStyle(
      fontFamily: "ElMessiri",
      fontWeight: FontWeight.w700,
      fontSize: size,
      color: Colors.white,
    ),
    speed: Duration(milliseconds: 300),
    curve: Curves.bounceInOut,
    pause: Duration(milliseconds: 0),
  );
}

Widget colorizedAnimatedText(String text) {
  return ColorizeAnimatedTextKit(
    totalRepeatCount: 10,
    text: [text],
    textStyle: TextStyle(
        // color: Colors.blue.shade800,
        fontSize: 20,
        fontWeight: FontWeight.bold),
    colors: [
      Colors.orange,
      Colors.white,
      Colors.white,
      Colors.green,
    ],
    isRepeatingAnimation: true,
    pause: Duration(milliseconds: 0),
    speed: Duration(milliseconds: 250),
  );
}

Widget logoSubtitle() {
  return Text(
    'Campus in your hand',
    style: TextStyle(
      fontFamily: "Merienda",
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
  );
}

Widget connectNowButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      print(FirebaseAuth.instance.currentUser);
      if (FirebaseAuth.instance.currentUser != null)
        Navigator.pushNamed(context, VetometerScreen.id);
      else
        Navigator.pushNamed(context, LoginScreen.id);
    },
    child: Container(
        height: 60,
        width: 225,
        margin: EdgeInsets.only(top: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text('Connect Now',
              style: TextStyle(
                color: Color(0xFF4F93CD),
                fontFamily: "Nunito",
                fontSize: 20,
                fontWeight: FontWeight.w700,
              )),
        )),
  );
}

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIconData;
  final bool obscureText;

  TextFieldWidget({
    this.hintText,
    this.prefixIconData,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Colors.white),
      ),
      child: TextField(
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          labelText: hintText,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            prefixIconData,
            size: 18,
            color: Colors.white,
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
