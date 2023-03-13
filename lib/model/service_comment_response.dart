import 'blog_comment_blog.dart';

class ServiceCommentResponse {
  int? statusCode;
  String? message;
  Data? data;

  ServiceCommentResponse({this.statusCode, this.message, this.data});

  ServiceCommentResponse.fromJson(Map<String, dynamic> json) {
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
  List<ServiceCommentsList>? serviceCommentsList;

  Data({this.totalCount, this.serviceCommentsList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['serviceCommentsList'] != null) {
      serviceCommentsList = <ServiceCommentsList>[];
      json['serviceCommentsList'].forEach((v) {
        serviceCommentsList?.add(new ServiceCommentsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.serviceCommentsList != null) {
      data['serviceCommentsList'] =
          this.serviceCommentsList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceCommentsList {
  String? userId;
  String? comment;
  int? insertDate;
  String? serviceCommentId;
  String? userName;
  String? userProfilePic;
  List<ReplyData>? replyData;
  String? eventCommentId;
  bool? showReplies;

  ServiceCommentsList(
      {this.userId,
      this.comment,
      this.insertDate,
      this.serviceCommentId,
      this.userName,
      this.userProfilePic,
      this.replyData,
      this.eventCommentId,
      this.showReplies});

  ServiceCommentsList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    comment = json['comment'];
    insertDate = json['insertDate'];
    serviceCommentId = json['serviceCommentId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    if (json['replyData'] != null) {
      replyData = <ReplyData>[];
      json['replyData'].forEach((v) {
        replyData?.add(new ReplyData.fromJson(v));
      });
    }
    eventCommentId = json['eventCommentId'];
    showReplies = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['insertDate'] = this.insertDate;
    data['serviceCommentId'] = this.serviceCommentId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    if (this.replyData != null) {
      data['replyData'] = this.replyData?.map((v) => v.toJson()).toList();
    }
    data['eventCommentId'] = this.eventCommentId;
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
//
//   ReplyData(
//       {this.comment,
//         this.insertDate,
//         this.replyCommentId,
//         this.userId,
//         this.userName,
//         this.userProfilePic});
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
