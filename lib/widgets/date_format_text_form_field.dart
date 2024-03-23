import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class DateFormatTextFormField extends StatelessWidget {
  final TextEditingController dateinput ;
  final String? labelText;
  final IconData? icon;
  final Color? color;
  void Function()? onTap;
   DateFormatTextFormField({Key? key,required this.dateinput,this.onTap,this.labelText,this.icon,this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: dateinput,
      decoration: InputDecoration(
        prefixIcon: Icon(icon,color: color,),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal,)
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.orange,
              width: 2,
            )
        ),

      ),
      readOnly: true,  //set it true, so that user will not able to edit text
      onTap: onTap,
    );
  }
}
