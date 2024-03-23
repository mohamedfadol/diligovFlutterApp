import 'board_model.dart';

class Boards {
  List<Board>? boards;

  Boards.fromJson(Map<String, dynamic> json) {
    if (json['boards'] != null) {
      boards = <Board>[];
      json['boards'].forEach((v) {
        boards!.add(Board.fromJson(v));
      });
    }
  }
}