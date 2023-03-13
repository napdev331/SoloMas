import 'package:solomas/helpers/common_helper.dart';

class GetGroupsModel {
  int? statusCode;

  String? message;

  GroupData? data;

  GetGroupsModel({this.statusCode, this.message, this.data});

  GetGroupsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? GroupData.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class GroupData {
  List<GroupList>? groupList;

  List<SubscriberList>? subscriberList;

  GroupData({this.groupList, this.subscriberList});

  GroupData.fromJson(Map<String, dynamic> json) {
    if (json['groupList'] != null) {
      groupList = <GroupList>[];

      json['groupList'].forEach((v) {
        groupList?.add(GroupList.fromJson(v));
      });
    }
    if (json['subscriberList'] != null) {
      subscriberList = <SubscriberList>[];

      json['subscriberList'].forEach((v) {
        subscriberList?.add(SubscriberList.fromJson(v));
      });
    }
  }
}

class GroupList {
  Location? location;

  int? totalSubscribers, insertDate;

  String? locationName, title, groupProfilePic, creationDate, groupId;

  bool? isJoined;

  GroupList(
      {this.location,
      this.totalSubscribers,
      this.locationName,
      this.title,
      this.groupProfilePic,
      this.creationDate,
      this.insertDate,
      this.groupId,
      this.isJoined});

  GroupList.fromJson(Map<String, dynamic> json) {
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;

    totalSubscribers = json['totalSubscribers'];

    locationName = json['locationName'];

    title = json['title'];

    groupProfilePic = json['groupProfilePic'];

    creationDate = json['creationDate'];

    insertDate = json['insertDate'];

    groupId = json['groupId'];

    isJoined = json['isJoined'];
  }
}

class Location {
  double? lat, lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];

    lng = json['lng'];
  }
}

class SubscriberList {
  String? subscriberId, userId, userName, userProfilePic;

  SubscriberList(
      {this.subscriberId, this.userId, this.userName, this.userProfilePic});

  SubscriberList.fromJson(Map<String, dynamic> json) {
    subscriberId = json['subscriberId'];

    userId = json['userId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'];
  }
}
