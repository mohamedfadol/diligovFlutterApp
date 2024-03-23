import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
class ContainerLabelWithBoxShadow extends StatelessWidget {

  String text;
   ContainerLabelWithBoxShadow({required this.text ,super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black54,
              blurRadius: 5.0,
              offset: Offset(0.0, 0.75)
          )
        ],
      ),
      child: Center(child: CustomText(text:text,
          color: Theme.of(context).iconTheme.color,fontSize: 14.0)),
    );
  }
}
