class Role {
  int? roleId;
  String? roleName;
  String? guardName;
  int? businessId;
  int? isDefault;
  String? createdAt;
  String? updatedAt;

  Role({this.roleId,
        this.roleName,
        this.guardName,
        this.businessId,
        this.isDefault,
        this.createdAt,
        this.updatedAt});

  Role.fromJson(Map<String, dynamic> json) {
    roleId = json['id'];
    roleName = json['name'];
    guardName = json['guard_name'];
    businessId = json['business_id'];
    isDefault = json['is_default'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = roleId;
    data['name'] = roleName;
    data['guard_name'] = guardName;
    data['business_id'] = businessId;
    data['is_default'] = isDefault;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
