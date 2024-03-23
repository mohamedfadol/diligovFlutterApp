import 'package:diligov/models/action_tracker_model.dart';
import 'package:diligov/models/member.dart';
import 'package:flutter/animation.dart';

class Notes{
  List<Note>? notes;
  Notes.fromJson(Map<String, dynamic> json) {
    if (json['notes'] != null) {
      notes = <Note>[];
      json['notes'].forEach((v) {
        notes!.add(Note.fromJson(v));
      });
    }
  }
}

class Note {
  int? noteId;
  String? noteText;
  String? noteDate;
  int? annotationId;
  Offset? position;
  String? fileEdited;
  int? pageIndex;
  Member? member;

  Note(
      {this.noteId,
        this.noteText,
        this.noteDate,
        this.annotationId,
        this.position,
        this.pageIndex,
        this.fileEdited,
        this.member,
      });
    // create new converter
    Note.fromJson(Map<String, dynamic> json) {
      noteId = json['id'];
      noteText = json['note'];
      pageIndex = json['page_index'];
      annotationId = json['annotation_id'];
      position = json['position'];
      fileEdited = json['file_edited'];
      noteDate = json['created_at'];
      member = json['member'] != null ? Member?.fromJson(json['member']) : null;
    }


}