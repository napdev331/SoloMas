class EventsLikeModel {
  int? statusCode;
  String? message;
  Data? data;

  EventsLikeModel({this.statusCode, this.message, this.data});

  EventsLikeModel.fromJson(Map<String, dynamic> json) {
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
  List<EventLikeList>? eventLikeList;

  Data({this.eventLikeList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['eventLikeList'] != null) {
      eventLikeList = <EventLikeList>[];
      json['eventLikeList'].forEach((v) {
        eventLikeList?.add(new EventLikeList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eventLikeList != null) {
      data['eventLikeList'] =
          this.eventLikeList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventLikeList {
  String? userId;
  String? eventLikeId;
  String? userName;
  String? userProfilePic;

  EventLikeList(
      {this.userId, this.eventLikeId, this.userName, this.userProfilePic});

  EventLikeList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    eventLikeId = json['eventLikeId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['eventLikeId'] = this.eventLikeId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    return data;
  }
}
