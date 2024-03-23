import 'package:flutter/material.dart';


class SystemButton extends StatelessWidget {
  SystemButton(this.buttonText, this.onPressed,this.colour,this.textColor,this.topPadding,this.rightPadding);
  final String buttonText;
  final VoidCallback onPressed;
  final Color colour;
  final Color textColor;
  final double topPadding;
  final double rightPadding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, right: rightPadding),
      child: Material(
        color: colour,
        elevation: 10,
        borderRadius: BorderRadius.circular(18),
        child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: textColor,
              padding: EdgeInsets.all(20),
              textStyle: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
            ),
            onPressed: onPressed,
            child: Text(buttonText)),
      ),
    );
  }
}