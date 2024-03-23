import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  bool get isDarkMode => themeMode == ThemeMode.dark;
  // bool get isDarkMode {
  //   if (themeMode == ThemeMode.system) {
  //     final brightness = SchedulerBinding.instance.window.platformBrightness;
  //     return brightness == Brightness.dark;
  //   } else {
  //     return themeMode == ThemeMode.dark;
  //   }
  // }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    print(themeMode);
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colour().mainColor,
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    colorScheme: const ColorScheme.dark(),
    iconTheme: IconThemeData(color: Colour().iconsGreyColor, opacity: 0.8),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.red, selectionHandleColor: Colors.blue),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colour().mainContentColor,
    brightness: Brightness.light,
    primaryColor: Colors.white,
    colorScheme: const ColorScheme.light(),
    iconTheme: IconThemeData(color: Colour().iconsGreyColor, opacity: 0.8),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.red, selectionHandleColor: Colors.blue),
  );
}