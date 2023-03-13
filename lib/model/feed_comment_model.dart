import 'package:solomas/helpers/common_helper.dart';

class FeedCommentModel {
  int? statusCode;

  String? message;

  Data? data;

  FeedCommentModel({this.statusCode, this.message, this.data});

  FeedCommentModel.fromJson(Map<String, dynamic> json) {
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
  bool? isNewComment, isReported;

  String? sId, publicFeedId, userId, comment;

  int? insertDate, iV;

  Data(
      {this.isNewComment,
      this.isReported,
      this.sId,
      this.publicFeedId,
      this.userId,
      this.comment,
      this.insertDate,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    isNewComment = json['isNewComment'];

    isReported = json['isReported'];

    sId = json['_id'];

    publicFeedId = json['publicFeedId'];

    userId = json['userId'];

    comment = json['comment'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
