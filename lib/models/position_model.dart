class Positions {
  List<Position>? positions;

  Positions({this.positions});

  Positions.fromJson(Map<String, dynamic> json) {
    if (json['positions'] != null) {
      positions =  <Position>[];
      json['positions'].forEach((v) {
        positions!.add(Position.fromJson(v));
      });
    }
  }


}

class Position {
  int? positionId;
  String? positionName;
  bool? isActive;
  bool? hasVote;
  int? businessId;

  Position(
      {this.positionId,
        this.positionName,
        this.isActive,
        this.hasVote,
        this.businessId});

  Position.fromJson(Map<String, dynamic> json) {
    positionId = json['id'];
    positionName = json['position_name'];
    isActive = json['is_active'];
    hasVote = json['has_vote'];
    businessId = json['business_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = positionId;
    data['position_name'] = positionName;
    data['is_active'] = isActive;
    data['has_vote'] = hasVote;
    data['business_id'] = businessId;
    return data;
  }
}
