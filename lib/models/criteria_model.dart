import 'package:diligov/models/user.dart';

import 'business_model.dart';

class Criterias {
  List<Criteria>? criterias;
  Criterias.fromJson(Map<String, dynamic> json) {
    if (json['criterias'] != null) {
      criterias = <Criteria>[];
      json['criterias'].forEach((v) {
        criterias!.add(Criteria.fromJson(v));
      });
    }
  }
}

class Criteria{
  int? criteriaId;
  String? criteriaCategory;
  String? criteriaText;
  int? businessId;
  int? createdBy;
  User? user;
  Business? business;


  Criteria(
      {this.criteriaId,
        this.criteriaCategory,
        this.criteriaText,
        this.createdBy,
        this.businessId,
        this.user,
        this.business,
      });

  // create new converter
  Criteria.fromJson(Map<String, dynamic> json) {
    criteriaId = json['id'];
    criteriaText = json['criteria_text'];
    criteriaCategory = json['criteria_category'];
    createdBy = json['created_by'];
    businessId = json['business_id'];
    user = User?.fromJson(json['user']);
    business = Business?.fromJson(json['business']);

  }


}