import 'package:flutter/material.dart';

import '../../core/constants/images_assets.dart';
class LoginImage extends StatelessWidget {
  // const LoginImage({Key? key}) : super(key: key);
  double? height;
  double? width;

  LoginImage({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Image.asset(ImagesAssets.loginLogo,height: height,width: width);
  }
}
