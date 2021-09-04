import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Color color;
  final String title;
  final Function onPressed;
  final double borderRadius, height, minWidth;

  RoundedButton(
      {this.color = Colors.indigoAccent,
      this.borderRadius = 15,
      this.height = 50,
      this.minWidth = double.infinity,
      @required this.title,
      @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: 20.0,
      child: MaterialButton(
        padding: EdgeInsets.all(0.0),
        onPressed: onPressed,
        minWidth: minWidth,
        height: height,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: "Nunito",
            fontWeight: FontWeight.bold,
          ),
        ),
        // Todo: Add animation later on, if possible.
        // animationDuration: ,
        // shape: ,
      ),
    );
  }
}
