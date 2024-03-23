import 'package:flutter/material.dart';

DataCell BuildDynamicDataCell({
  required Widget child,
  bool placeholder = false,
  bool showEditIcon = false,
  void Function()? onTap,
  void Function()? onLongPress,
  void Function(TapDownDetails)? onTapDown,
  void Function()? onDoubleTap,
  void Function()? onTapCancel,
}) {
  return DataCell(
    child,
    placeholder: placeholder,
    showEditIcon: showEditIcon,
    onTap: onTap,
    onLongPress: onLongPress,
    onTapDown: onTapDown,
    onDoubleTap: onDoubleTap,
    onTapCancel: onTapCancel,
  );
}
