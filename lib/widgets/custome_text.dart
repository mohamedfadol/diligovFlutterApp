import 'dart:ui';

import 'package:flutter/material.dart';
class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool? softWrap;
  final int? maxLines;
  final TextOverflow? overflow;
  CustomText({super.key, required this.text, this.color, this.fontWeight, this.fontSize,this.softWrap,this.maxLines,this.overflow});

  @override
  Widget build(BuildContext context) {
    return Text(text,style: TextStyle(color: color, fontSize: fontSize,fontWeight: fontWeight),
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow,);
  }
}


