import 'package:solomas/helpers/common_helper.dart';

class ParticipantListModel {
  int? statusCode;

  String? message;

  Data? data;

  ParticipantListModel({this.statusCode, this.message, this.data});

  ParticipantListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  List<RoadKingQueenList>? roadKingQueenList;

  Data({this.roadKingQueenList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['roadKingQueenList'] != null) {
      roadKingQueenList = <RoadKingQueenList>[];

      json['roadKingQueenList'].forEach((v) {
        roadKingQueenList?.add(RoadKingQueenList.fromJson(v));
      });
    }
  }
}

class RoadKingQueenList {
  int? totalVotes, insertDate;

  String? carnivalId, userId, userName, type, image, roadKingQueenId;

  bool? isVote;

  RoadKingQueenList(
      {this.totalVotes,
      this.carnivalId,
      this.userId,
      this.type,
      this.image,
      this.insertDate,
      this.roadKingQueenId,
      this.isVote,
      this.userName});

  RoadKingQueenList.fromJson(Map<String, dynamic> json) {
    totalVotes = json['totalVotes'];

    carnivalId = json['carnivalId'];

    userId = json['userId'];

    userName = json['userName'];

    type = json['type'];

    image = json['image'];

    insertDate = json['insertDate'];

    roadKingQueenId = json['roadKingQueenId'];

    isVote = json['isVote'];
  }
}
