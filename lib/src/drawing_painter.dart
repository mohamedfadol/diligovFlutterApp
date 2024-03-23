
import 'dart:ui' as ui;
import 'package:diligov/src/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawingPainter extends CustomPainter {
  List<Stroke> strokes;

  DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        if (stroke.points[i] != null && stroke.points[i + 1] != null) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], stroke.paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
