import 'blog_comment_blog.dart';

class EventCommentResponse {
  int? statusCode;
  String? message;
  Data? data;

  EventCommentResponse({this.statusCode, this.message, this.data});

  EventCommentResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  int? totalCount;
  List<EventCommentsList>? eventCommentsList;

  Data({this.totalCount, this.eventCommentsList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['eventCommentsList'] != null) {
      eventCommentsList = <EventCommentsList>[];
      json['eventCommentsList'].forEach((v) {
        eventCommentsList?.add(new EventCommentsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.eventCommentsList != null) {
      data['eventCommentsList'] =
          this.eventCommentsList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventCommentsList {
  String? userId;
  String? comment;
  int? insertDate;
  String? eventCommentId;
  String? userName;
  String? userProfilePic;
  List<ReplyData>? replyData;
  bool? showReplies;

  EventCommentsList(
      {this.userId,
      this.comment,
      this.insertDate,
      this.eventCommentId,
      this.userName,
      this.userProfilePic,
      this.replyData,
      this.showReplies});

  EventCommentsList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    comment = json['comment'];
    insertDate = json['insertDate'];
    eventCommentId = json['eventCommentId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    if (json['replyData'] != null) {
      replyData = <ReplyData>[];
      json['replyData'].forEach((v) {
        replyData?.add(new ReplyData.fromJson(v));
      });
    }
    showReplies = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['insertDate'] = this.insertDate;
    data['eventCommentId'] = this.eventCommentId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    if (this.replyData != null) {
      data['replyData'] = this.replyData?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class ReplyData {
//   String? comment;
//   int? insertDate;
//   String? replyCommentId;
//   String? userId;
//   String? userName;
//   String? userProfilePic;
//
//   ReplyData(
//       {this.comment,
//       this.insertDate,
//       this.replyCommentId,
//       this.userId,
//       this.userName,
//       this.userProfilePic});
//
//   ReplyData.fromJson(Map<String, dynamic> json) {
//     comment = json['comment'];
//     insertDate = json['insertDate'];
//     replyCommentId = json['replyCommentId'];
//     userId = json['userId'];
//     userName = json['userName'];
//     userProfilePic = json['userProfilePic'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['comment'] = this.comment;
//     data['insertDate'] = this.insertDate;
//     data['replyCommentId'] = this.replyCommentId;
//     data['userId'] = this.userId;
//     data['userName'] = this.userName;
//     data['userProfilePic'] = this.userProfilePic;
//     return data;
//   }
// }
