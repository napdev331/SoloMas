import 'package:solomas/helpers/common_helper.dart';

class JoinCarnivalModel {
  int? statusCode;

  String? message;

  Data? data;

  JoinCarnivalModel({this.statusCode, this.message, this.data});

  JoinCarnivalModel.fromJson(Map<String, dynamic> json) {
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
  String? sId, userId, carnivalId, creationDate;

  int? insertDate, iV;

  Data(
      {this.sId,
      this.userId,
      this.carnivalId,
      this.creationDate,
      this.insertDate,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    userId = json['userId'];

    carnivalId = json['carnivalId'];

    creationDate = json['creationDate'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
