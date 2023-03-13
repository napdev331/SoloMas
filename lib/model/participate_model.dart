import 'package:solomas/helpers/common_helper.dart';

class ParticipateModel {
  int? statusCode;

  String? message;

  Datum? data;

  ParticipateModel({this.statusCode, this.message, this.data});

  ParticipateModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? Datum.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Datum {
  String? sId, carnivalId, userId, type, image;

  int? totalVotes, insertDate, iV;

  bool? isReported;

  Datum(
      {this.totalVotes,
      this.isReported,
      this.sId,
      this.carnivalId,
      this.userId,
      this.type,
      this.image,
      this.insertDate,
      this.iV});

  Datum.fromJson(Map<String, dynamic> json) {
    totalVotes = json['totalVotes'];

    isReported = json['isReported'];

    sId = json['_id'];

    carnivalId = json['carnivalId'];

    userId = json['userId'];

    type = json['type'];

    image = json['image'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
