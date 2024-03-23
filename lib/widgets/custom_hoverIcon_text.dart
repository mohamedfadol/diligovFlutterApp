import 'package:flutter/material.dart';
class CustomHoverIconText extends StatefulWidget {
  final IconData iconData;
  final String hoverText;
  const CustomHoverIconText({super.key, required this.iconData, required this.hoverText});

  @override
  State<CustomHoverIconText> createState() => _CustomHoverIconTextState();
}

class _CustomHoverIconTextState extends State<CustomHoverIconText> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (event) => setState(() => _isHovering = true),
          onExit: (event) => setState(() => _isHovering = false),
          child: Icon(
            widget.iconData,
            size: 50,
          ),
        ),
        if (_isHovering)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.hoverText,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
