import 'package:flutter/material.dart';
class CustomIcon extends StatelessWidget {
  CustomIcon({ required this.icon, this.size, this.color});
  final IconData icon;
  final double? size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.black,
      child: Icon(icon,size: size,color:color),
    );
  }
}
