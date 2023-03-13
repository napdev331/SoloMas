import 'package:solomas/helpers/common_helper.dart';

class JoinGroupModel {
  int? statusCode;

  String? message;

  Data? data;

  JoinGroupModel({this.statusCode, this.message, this.data});

  JoinGroupModel.fromJson(Map<String, dynamic> json) {
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
  String? sId, userId, groupId, creationDate;

  int? insertDate, iV;

  Data(
      {this.sId,
      this.userId,
      this.groupId,
      this.creationDate,
      this.insertDate,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    userId = json['userId'];

    groupId = json['groupId'];

    creationDate = json['creationDate'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
