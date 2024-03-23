import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
class MenuButton extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;

  MenuButton({Key? key, required this.text,this.fontWeight, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Text(text,style: TextStyle(color: themeProvider.isDarkMode == true ? Colors.white : Colors.black, fontSize: fontSize,fontWeight: fontWeight),);
  }
}
