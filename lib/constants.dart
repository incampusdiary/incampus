import 'package:flutter/material.dart';

TextStyle textStyle = TextStyle(
    color: Colors.black, fontSize: 20, textBaseline: TextBaseline.alphabetic);

const kTextDecorationStyle = InputDecoration(
  // contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 0),
  enabled: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  fillColor: Color(0xFFB3E5FC),
  filled: true,
);

const kGradientColor = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0052D4), Color(0xFF6FB1FC)],
  ),
);
