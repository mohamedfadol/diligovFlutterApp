class InsertMinutesModel {
  final int agendaId;
  final String minuteDate;
  final String minuteDecision;
  final String meetingId;
  final String boardId;
  final String addBy;
  final String minuteName;
 final String businessId;

  InsertMinutesModel(
      {required this.agendaId,
      required this.minuteName,
      required this.meetingId,
      required this.minuteDate,
      required this.minuteDecision,
      required this.businessId,
      required this.addBy,
      required this.boardId});

}