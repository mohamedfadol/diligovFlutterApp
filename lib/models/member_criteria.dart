class MemberCriteria {
  int? index;
  int? criteriaId;
  int? electedBy;
  int? businessId;
  int? criteriaDegree;
  MemberCriteria({
    required this.index,
     this.criteriaId,
     this.electedBy,
     this.criteriaDegree,
     this.businessId
  });


  @override
  bool operator ==(other) {
    if (other is! MemberCriteria) {
      return false;
    }
    return index == other.index &&
        criteriaId == other.criteriaId;
  }

  @override
  int get hashCode => (index! + criteriaId!).hashCode;
}