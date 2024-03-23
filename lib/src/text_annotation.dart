import 'package:flutter/animation.dart';

import 'package:flutter/material.dart';

class TextAnnotation {
  final Offset position;
  String text;
  int id;
  Color color;
  TextAnnotation({required this.position, required this.text, required this.id, required this.color,});
}
