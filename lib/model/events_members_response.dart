import 'package:solomas/model/carnival_list_model.dart';

class EventsMemberResponse {
  int? statusCode;
  String? message;
  Data? data;

  EventsMemberResponse({this.statusCode, this.message, this.data});

  EventsMemberResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;

    return data;
  }
}

class Data {
  int? totalCount;
  List<MembersList>? eventMemberList;

  Data({this.totalCount, this.eventMemberList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['eventMemberList'] != null) {
      eventMemberList = <MembersList>[];
      json['eventMemberList'].forEach((v) {
        eventMemberList?.add(new MembersList.fromJson(v));
      });
    }
  }
}

class EventMemberList {
  String? userId;
  String? userName;
  String? userProfilePic;

  EventMemberList({this.userId, this.userName, this.userProfilePic});

  EventMemberList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    return data;
  }
}
