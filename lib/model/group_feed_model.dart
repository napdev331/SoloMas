class GroupFeedModel {
  int? statusCode;

  String? message;

  Data? data;

  GroupFeedModel({this.statusCode, this.message, this.data});

  GroupFeedModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<CarnivalFeedList>? carnivalFeedList;

  Data({this.carnivalFeedList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['carnivalFeedList'] != null) {
      carnivalFeedList = <CarnivalFeedList>[];

      json['carnivalFeedList'].forEach((v) {
        carnivalFeedList?.add(CarnivalFeedList.fromJson(v));
      });
    }
  }
}

class CarnivalFeedList {
  int? totalLikes, totalComments, insertDate;

  bool? isReported, isLike;

  String? userId, groupId, comment, carnivalFeedId, userName, userProfilePic;

  CarnivalFeedList(
      {this.totalLikes,
      this.totalComments,
      this.isReported,
      this.userId,
      this.groupId,
      this.comment,
      this.insertDate,
      this.carnivalFeedId,
      this.userName,
      this.userProfilePic,
      this.isLike});

  CarnivalFeedList.fromJson(Map<String, dynamic> json) {
    totalLikes = json['totalLikes'];

    totalComments = json['totalComments'];

    isReported = json['isReported'];

    userId = json['userId'];

    groupId = json['groupId'];

    comment = json['comment'];

    insertDate = json['insertDate'];

    carnivalFeedId = json['carnivalFeedId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'];

    isLike = json['isLike'];
  }
}
