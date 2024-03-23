
import 'package:diligov/models/meeting_model.dart';
import 'package:diligov/models/member.dart';

import 'business_model.dart';

class Board {
   int? boarId;
   String? term;
   String? boardName;
   String? quorum;
   String? fiscalYear;
   String? serialNumber;
   String? charterBoard;
   bool? isExpanded = true;
   Business? business;
   List<Member>? members;
   List<Meeting>? meetings;

  Board({
       this.boarId, this.boardName, this.term, this.quorum, this.fiscalYear, this.serialNumber,this.charterBoard, this.business,this.members, this.meetings});

   Board.fromJson(Map<String, dynamic> json) {
          boarId= json['id'];
          term= json['term'];
          boardName= json['board_name'];
          quorum= json['quorum'];
          fiscalYear= json['fiscal_year'];
          serialNumber= json['serial_number'];
          charterBoard= json['charter_board'];
          business =  json['business'] != null ? Business.fromJson(json['business']) : null;
          if (json['members'] != null) {
            members = <Member>[];
            json['members'].forEach((v) {
              members!.add(Member.fromJson(v));
            });
          }
          if (json['meetings'] != null) {
            meetings = <Meeting>[];
            json['meetings'].forEach((v) {
              meetings!.add(Meeting.fromJson(v));
            });
          }
   }

}