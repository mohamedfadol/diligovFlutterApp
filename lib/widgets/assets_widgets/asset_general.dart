import 'package:flutter/material.dart';

import '../../core/constants/images_assets.dart';
class AssetGeneral extends StatelessWidget {
  double? height;
  double? width;
  String image;

  AssetGeneral({super.key, required this.image,this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Image.asset(image,height: height,width: width);
  }
}
