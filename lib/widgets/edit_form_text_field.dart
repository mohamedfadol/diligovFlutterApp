import 'package:flutter/material.dart';

import 'custome_text.dart';
class EditFormTextField extends StatelessWidget {
  final String? Function(String?) valid;
  final String text;
  final String? hintText;
  final Color? color;
  final FontWeight? Fontweight;
  final double? fontsize;
  final TextEditingController? myController;

   EditFormTextField({Key? key ,required this.valid,
                     required this.text,
                     this.myController,
                     this.hintText,
                     this.color,this.Fontweight,
                     this.fontsize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: text,color: color,fontSize: fontsize,fontWeight: Fontweight),
        SizedBox(height: 8,),
        TextFormField(
          controller: myController,
          validator: valid,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold,),
            contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 3, color: Colors.grey),
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        )
      ],
    );
  }
}
