import 'package:solomas/helpers/common_helper.dart';

class RoadKingQueenVoteModel {
  int? statusCode;

  String? message;

  Data? data;

  RoadKingQueenVoteModel({this.statusCode, this.message, this.data});

  RoadKingQueenVoteModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  String? sId, roadKingQueenId, userId, type;

  int? insertDate, iV;

  Data(
      {this.sId,
      this.roadKingQueenId,
      this.userId,
      this.type,
      this.insertDate,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    roadKingQueenId = json['roadKingQueenId'];

    userId = json['userId'];

    type = json['type'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
