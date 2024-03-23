import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
class CustomMessage extends StatelessWidget {
  final String text;
  CustomMessage({Key? key,required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white,width: 1.0)
        ),
        padding: const EdgeInsets.all(20.0),
        child: Center(child: CustomText(text:text,fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.red,),)
    );
  }
}
