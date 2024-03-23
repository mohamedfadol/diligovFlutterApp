import 'agenda_model.dart';

class AgendaDetails{
  int? agendaId;
  int? index;
  int? detailsId;
  String?  missions;
  String?  tasks;
  String?  reservations;
  Agenda? agenda;

  AgendaDetails({this.index,this.detailsId,this.missions, this.tasks, this.reservations,this.agendaId,this.agenda});

  AgendaDetails.fromJson(Map<String, dynamic> json) {
    detailsId = json['id'];
    agendaId = json['agenda_id'];
    missions = json['missions'];
    tasks = json['tasks'];
    agenda = json['agenda'] != null ? Agenda.fromJson(json['agenda']) : null;
    reservations = json['reservations'];
  }

  @override
  bool operator ==(other) {
    if (other is! AgendaDetails) {
      return false;
    }
    return index == other.index &&
        agendaId == other.agendaId;
  }

  @override
  int get hashCode => ( index! + agendaId!).hashCode;
}