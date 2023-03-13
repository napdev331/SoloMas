import 'package:solomas/helpers/common_helper.dart';

class UpdateCarnivalFeedModel {
  int? statusCode;

  String? message;

  Data? data;

  UpdateCarnivalFeedModel({this.statusCode, this.message, this.data});

  UpdateCarnivalFeedModel.fromJson(Map<String, dynamic> json) {
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
  int? totalLikes, totalComments, insertDate, iV;

  bool? isReported;

  String? sId, userId, groupId, comment;

  Data(
      {this.totalLikes,
      this.totalComments,
      this.isReported,
      this.sId,
      this.userId,
      this.groupId,
      this.comment,
      this.insertDate,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    totalLikes = json['totalLikes'];

    totalComments = json['totalComments'];

    isReported = json['isReported'];

    sId = json['_id'];

    userId = json['userId'];

    groupId = json['groupId'];

    comment = json['comment'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
