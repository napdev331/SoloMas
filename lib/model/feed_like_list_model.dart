import 'package:solomas/helpers/common_helper.dart';

class FeedLikeListModel {
  int? statusCode;

  String? message;

  Data? data;

  FeedLikeListModel({this.statusCode, this.message, this.data});

  FeedLikeListModel.fromJson(Map<String, dynamic> json) {
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
  List<PublicLikeList>? publicLikeList;

  Data({this.publicLikeList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['publicLikeList'] != null) {
      publicLikeList = <PublicLikeList>[];

      json['publicLikeList'].forEach((v) {
        publicLikeList?.add(new PublicLikeList.fromJson(v));
      });
    }
  }
}

class PublicLikeList {
  String? userName, userProfilePic, publicLikeId, userId;

  PublicLikeList(
      {this.publicLikeId,
      this.userName,
      this.userProfilePic = "",
      this.userId});

  PublicLikeList.fromJson(Map<String, dynamic> json) {
    publicLikeId = json['publicLikeId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'];

    userId = json['userId'];
  }
}
