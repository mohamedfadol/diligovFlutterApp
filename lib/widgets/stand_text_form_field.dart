import 'package:flutter/material.dart';
class StandTextFormField extends StatelessWidget {
  final TextEditingController? controllerField;
  final String? labelText;
  final String? hintText;
  final IconData? icon;
  final Color? color;
  final String? Function(String?) valid;
   StandTextFormField({Key? key,required this.valid, this.controllerField,this.labelText,this.hintText,this.icon,this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: valid,
      controller: controllerField,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal,)
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.orange,
              width: 2,
            )
        ),
        prefixIcon: Icon(icon,color: color,),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: const TextStyle(color: Colors.black),
        hintText: hintText,
          errorStyle: const TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),
      ),
    );
  }
}
