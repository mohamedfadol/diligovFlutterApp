import 'package:flutter/material.dart';

String validateEmail(String value) {
  String _msg = 'Error Occur';
  RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (value.isEmpty) {
    _msg = "Your username is required";
  } else if (!regex.hasMatch(value)) {
    _msg = "Please provide a valid emal address";
  }
  return _msg;
}


Widget nameTextField() {
  return TextFormField(
    // controller: _name,
    // validator: (value) {
    //   if (value.isEmpty) return "Name can't be empty";
    //
    //   return null;
    // },
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal,
          )),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          )),
      prefixIcon: Icon(
        Icons.person,
        color: Colors.green,
      ),
      labelText: "Name",
      helperText: "Name can't be empty",
      hintText: "Dev Stack",
    ),
  );
}

Widget professionTextField() {
  return TextFormField(
    // controller: _profession,
    // validator: (value) {
    //   if (value.isEmpty) return "Profession can't be empty";
    //
    //   return null;
    // },
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal,
          )),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          )),
      prefixIcon: Icon(
        Icons.person,
        color: Colors.green,
      ),
      labelText: "Profession",
      helperText: "Profession can't be empty",
      hintText: "Full Stack Developer",
    ),
  );
}

Widget dobField() {
  return TextFormField(
    // controller: _dob,
    // validator: (value) {
    //   if (value.isEmpty) return "DOB can't be empty";
    //
    //   return null;
    // },
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal,
          )),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          )),
      prefixIcon: Icon(
        Icons.person,
        color: Colors.green,
      ),
      labelText: "Date Of Birth",
      helperText: "Provide DOB on dd/mm/yyyy",
      hintText: "01/01/2020",
    ),
  );
}

Widget titleTextField() {
  return TextFormField(
    // controller: _title,
    // validator: (value) {
    //   if (value.isEmpty) return "Title can't be empty";
    //
    //   return null;
    // },
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal,
          )),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          )),
      prefixIcon: Icon(
        Icons.person,
        color: Colors.green,
      ),
      labelText: "Title",
      helperText: "It can't be empty",
      hintText: "Flutter Developer",
    ),
  );
}

Widget aboutTextField() {
  return TextFormField(
    // controller: _about,
    // validator: (value) {
    //   if (value.isEmpty) return "About can't be empty";
    //
    //   return null;
    // },
    maxLines: 4,
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal,
          )),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          )),
      labelText: "About",
      helperText: "Write about yourself",
      hintText: "I am Dev Stack",
    ),
  );
}