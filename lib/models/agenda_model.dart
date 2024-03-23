import 'package:diligov/models/agenda_details.dart';

class Agendas {
  List<Agenda>? agendas;
  Agendas.fromJson(Map<String, dynamic> json) {
    if (json['agendas'] != null) {
      agendas = <Agenda>[];
      json['agendas'].forEach((v) {
        agendas!.add(Agenda.fromJson(v));
      });
    }
  }

}

class Agenda{
  int? agendaId;
  String? agendaTitle;
  String? agendaDescription;
  String? agendaTime;
  int? presenter;
  String? agendaFile;
  String? agendaFileName;
  String? agendaFileFullPath;
  bool isClicked = false;

  List<AgendaDetails>? agendaDetails;

  Agenda({this.agendaId,
        this.agendaTitle,
        this.agendaDescription,
        this.agendaTime,
        this.presenter,
        this.agendaDetails,
        this.agendaFile,
        this.agendaFileFullPath,
        this.agendaFileName
      });

   Agenda.fromJson(Map<String, dynamic> json) {
      agendaId= json['id'];
      agendaTitle= json['agenda_title'];
      agendaDescription= json['agenda_description'];
      agendaTime= json['agenda_time'];
      presenter =json['agenda_presenter'];
      agendaFile =json['agenda_file'];
      agendaFileFullPath =json['file_full_path'];
      agendaFileName =json['file_name'];
      if (json['agenda_details'] != null) {
        agendaDetails = <AgendaDetails>[];
        json['agenda_details'].forEach((v) {
          agendaDetails!.add(AgendaDetails.fromJson(v));
        });
      }
  }

}