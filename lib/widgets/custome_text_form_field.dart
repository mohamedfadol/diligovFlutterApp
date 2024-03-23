import 'package:flutter/material.dart';

import 'custom_icon.dart';
import 'custome_text.dart';

class CustomeTextFormField extends StatelessWidget {
  CustomeTextFormField(
      { Key? key,
        required this.valid,
        required this.myController,
        required this.lableText,
        required this.prefixIcon,
        this.suffixIcon,
        this.obSecureText,
        required this.borderRadius,
        required this.hintText}) : super(key: key);

  final String lableText;
  final bool? obSecureText;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final double borderRadius;
  final String? Function(String?) valid;
  final TextEditingController? myController;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 300),
      child: TextFormField(
        validator: valid,
        controller: myController,
        obscureText: obSecureText == null ? false : true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding:  EdgeInsets.symmetric(vertical: 1.0),
            label: CustomText(text: lableText),
            labelStyle: const TextStyle(color: Colors.black),
            prefixIcon: CustomIcon(icon: prefixIcon,color: Theme.of(context).iconTheme.color,),
            suffixIcon: Icon(suffixIcon,color: Theme.of(context).iconTheme.color,),
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black,),
              borderRadius: BorderRadius.circular(borderRadius),
            )
        ),
      ),
    );
  }


}
