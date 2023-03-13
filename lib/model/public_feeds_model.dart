import 'package:solomas/helpers/common_helper.dart';

class PublicFeedsModel {
  int? statusCode;

  String? message;

  Data? data;

  PublicFeedsModel({this.statusCode, this.message, this.data});

  PublicFeedsModel.fromJson(Map<String, dynamic> json) {
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
  List<PublicFeedList>? publicFeedList;

  Data({this.publicFeedList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['publicFeedList'] != null) {
      publicFeedList = <PublicFeedList>[];

      json['publicFeedList'].forEach((v) {
        publicFeedList?.add(new PublicFeedList.fromJson(v));
      });
    }
  }
}

class PublicFeedList {
  int? totalLikes, insertDate, totalComments;

  String? userId,
      publicFeedId,
      userName,
      userProfilePic,
      type,
      title,
      description;

  List<String>? image;

  bool? isLike;
  int? sliderPosition;

  PublicFeedList(
      {this.totalLikes,
      this.totalComments,
      this.userId,
      this.insertDate,
      this.publicFeedId,
      this.userName,
      this.userProfilePic,
      this.image,
      this.isLike,
      this.type,
      this.title,
      this.description,
      this.sliderPosition});

  PublicFeedList.fromJson(Map<String, dynamic> json) {
    totalLikes = json['totalLikes'];

    totalComments = json['totalComments'];

    userId = json['userId'];

    insertDate = json['insertDate'];

    publicFeedId = json['publicFeedId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'] ?? "";

    image = json['image'].cast<String>();
    // type = json['type'] ?? "image";
    type = json['type'];

    title = json['title'] ?? "";

    description = json['description'] ?? "";

    isLike = json['isLike'];

    sliderPosition = 0;
  }
}
