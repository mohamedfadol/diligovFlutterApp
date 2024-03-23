import 'package:diligov/models/agenda_details.dart';
import 'package:diligov/models/business_model.dart';
import 'package:diligov/models/meeting_model.dart';
import 'package:diligov/models/member.dart';

class ActionsTrackers {
  List<ActionTracker>? actions;
  ActionsTrackers.fromJson(Map<String, dynamic> json) {
    if (json['actions'] != null) {
      actions = <ActionTracker>[];
      json['actions'].forEach((v) {
        actions!.add(ActionTracker.fromJson(v));
      });
    }
  }

}

class ActionTracker{
  int? actionsId;
  String? actionsTasks;
  String? actionStatus;
  String? actionNote;
  String? actionsDateDue;
  String? actionsDateAssigned;
  AgendaDetails? agendaDetails;
  Meeting? meeting;
  Member? member;
  Business? business;

  ActionTracker({
        this.actionsId,
        this.actionsTasks,
        this.actionStatus,
        this.actionNote,
        this.actionsDateDue,
        this.actionsDateAssigned,
        this.agendaDetails,
        this.meeting,
        this.member,
        this.business
      });

  ActionTracker.fromJson(Map<String, dynamic> json) {
      actionsId= json['id'];
      actionsTasks= json['tasks'];
      actionStatus =json['action_status'];
      actionNote =json['note'];
      actionsDateDue= json['date_due'];
      actionsDateAssigned= json['date_assigned'];
      agendaDetails = json['details'] != null ? AgendaDetails.fromJson(json['details']) : null;
      meeting = json['meeting'] != null ? Meeting.fromJson(json['meeting']) : null;
      member = json['member'] != null ? Member.fromJson(json['member']) : null;
      business = json['business'] != null ? Business.fromJson(json['business']) : null;
  }

}