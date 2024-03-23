import 'dart:convert';

import 'package:diligov/models/role.dart';

class Roles {
  List<Role>? roles;
  Roles({this.roles});
  Roles.fromJson(Map<String, dynamic> json) {
    if (json['roles'] != null) {
      roles = <Role>[];
      json['boards'].forEach((v) {
        roles!.add(Role.fromJson(v));
      });
    }
  }
}

