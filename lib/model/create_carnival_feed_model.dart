import 'package:solomas/helpers/common_helper.dart';

class CreateCarnivalFeedModel {
  int? statusCode;

  String? message;

  Data? data;

  CreateCarnivalFeedModel({this.statusCode, this.message, this.data});

  CreateCarnivalFeedModel.fromJson(Map<String, dynamic> json) {
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
  int? totalLikes, totalComments, insertDate, iV;

  bool? isReported;

  String? sId, userId, carnivalId, comment;

  Data(
      {this.totalLikes,
      this.totalComments,
      this.isReported,
      this.sId,
      this.userId,
      this.carnivalId,
      this.comment,
      this.insertDate,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    totalLikes = json['totalLikes'];

    totalComments = json['totalComments'];

    isReported = json['isReported'];

    sId = json['_id'];

    userId = json['userId'];

    carnivalId = json['carnivalId'];

    comment = json['comment'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
