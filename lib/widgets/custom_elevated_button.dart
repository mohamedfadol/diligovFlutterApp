import 'package:diligov/widgets/custom_icon.dart';
import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
class CustomElevatedButton extends StatelessWidget {
  final void Function() callFunction;
  final String text;
  final Color? textColor;
  final Color? iconColor;
  final Color? buttonBackgroundColor;
  final IconData icon;
  final double? iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  const CustomElevatedButton(
    {Key? key,
      required this.text,
      required this.callFunction,
      this.textColor,
      required this.icon,
      this.iconColor,
      this.iconSize,
      this.buttonBackgroundColor,
      required this.horizontalPadding,
      required this.verticalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: CustomText(
        text: text,color:textColor,),
      icon: CustomIcon(icon: icon,color: iconColor,size: iconSize,),
      onPressed: callFunction,
      style: ElevatedButton
          .styleFrom(
          backgroundColor: buttonBackgroundColor,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding,vertical: verticalPadding)),
    );
  }
}
