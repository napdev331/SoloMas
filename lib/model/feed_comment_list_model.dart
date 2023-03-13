import 'package:solomas/helpers/common_helper.dart';

import 'blog_comment_blog.dart';

class FeedCommentListModel {
  int? statusCode;

  String? message;

  Data? data;

  FeedCommentListModel({this.statusCode, this.message, this.data});

  FeedCommentListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(
          statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  List<PublicCommentsList>? publicCommentsList;

  Data({this.publicCommentsList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['publicCommentsList'] != null) {
      publicCommentsList = <PublicCommentsList>[];

      json['publicCommentsList'].forEach((v) {
        publicCommentsList?.add(new PublicCommentsList.fromJson(v));
      });
    }
  }
}

class PublicCommentsList {
  String? comment, publicCommentId, userName, userProfilePic, userId;

  int? insertDate;

  List<ReplyData>? replyData;

  bool? showReplies;

  PublicCommentsList(
      {this.comment,
      this.insertDate,
      this.publicCommentId,
      this.userName,
      this.userProfilePic,
      this.replyData,
      this.showReplies,
      this.userId});

  PublicCommentsList.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];

    insertDate = json['insertDate'];

    publicCommentId = json['publicCommentId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'];

    userId = json['userId'];

    if (json['replyData'] != null) {
      replyData = <ReplyData>[];

      json['replyData'].forEach((v) {
        replyData?.add(ReplyData.fromJson(v));
      });
    }
    showReplies = false;
  }
}

// class ReplyData {
//   int? insertDate;
//
//   String? comment, userId, userName, userProfilePic, replyCommentId;
//
//   ReplyData(
//       {this.comment,
//       this.insertDate,
//       this.userId,
//       this.userName,
//       this.replyCommentId,
//       this.userProfilePic});
//
//   ReplyData.fromJson(Map<String, dynamic> json) {
//     comment = json['comment'];
//
//     insertDate = json['insertDate'];
//
//     userId = json['userId'];
//
//     userName = json['userName'];
//
//     userProfilePic = json['userProfilePic'];
//
//     replyCommentId = json['replyCommentId'];
//   }
// }
