import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';

class LebleAndData extends StatelessWidget {
  LebleAndData({super.key, this.dataName, this.size, this.lebaleName});
  final String? dataName;
  final String? lebaleName;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: lebaleName!,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(
          height: size,
        ),
        CustomText(text: dataName!, fontSize: 15, fontWeight: FontWeight.bold),
      ],
    );
  }
}
