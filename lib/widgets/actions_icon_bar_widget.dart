import 'package:diligov/widgets/custom_icon.dart';
import 'package:flutter/material.dart';

class ActionsIconBarWidget extends StatelessWidget {
  const ActionsIconBarWidget
      ({super.key,
          required this.onPressed,
          required this.buttonIcon, this.buttonIconSize,
          this.buttonIconColor, required this.boxShadowColor,
          required this.boxShadowBlurRadius,
          required this.boxShadowSpreadRadius,
          required this.containerBorderRadius,
          required this.containerBackgroundColor,
      });
    final VoidCallback onPressed;
    final IconData buttonIcon;
    final double? buttonIconSize;
    final Color? buttonIconColor;
    final Color boxShadowColor;
    final double boxShadowBlurRadius;
    final double boxShadowSpreadRadius;
    final double containerBorderRadius;
    final Color? containerBackgroundColor;
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
          color: containerBackgroundColor,
          borderRadius: BorderRadius.circular(containerBorderRadius),
          boxShadow: [
            BoxShadow(color: boxShadowColor, blurRadius: boxShadowBlurRadius, spreadRadius: boxShadowSpreadRadius)
          ]
      ),
      child: IconButton(
        icon: CustomIcon(
          icon: buttonIcon,
          size: buttonIconSize,
          color: buttonIconColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
