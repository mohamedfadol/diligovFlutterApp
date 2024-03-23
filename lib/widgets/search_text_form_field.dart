import 'package:flutter/material.dart';

import 'custom_icon.dart';
class SearchTextFormField extends StatelessWidget {
  final String? lableText;
  final String hintText;
  final IconData? prefixIcon;
  final double? borderRadius;

  SearchTextFormField(
      {this.lableText, required this.hintText, this.prefixIcon, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:  BorderRadius.circular(30.0),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
          ]),
      child: TextFormField(
        decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
            hintText: hintText,
            prefixIcon: CustomIcon(icon: Icons.search,color: Theme.of(context).iconTheme.color,) ,
            hintStyle: TextStyle(fontSize: 14,color: Colors.grey[600],fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            )
        ),
      ),
    );
  }
}
