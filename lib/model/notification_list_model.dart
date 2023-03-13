import 'package:solomas/helpers/common_helper.dart';

class NotificationListModel {
  int? statusCode;

  String? message;

  Data? data;

  NotificationListModel({this.statusCode, this.message, this.data});

  NotificationListModel.fromJson(Map<String, dynamic> json) {
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
  List<NotificationList>? notificationList;

  Data({this.notificationList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['notificationList'] != null) {
      notificationList = <NotificationList>[];

      json['notificationList'].forEach((v) {
        notificationList?.add(new NotificationList.fromJson(v));
      });
    }
  }
}

class NotificationList {
  String? sId,
      id,
      message,
      title,
      type,
      senderId,
      receiverId,
      insertDate,
      senderProfilePic,
      senderName;

  int? creationDate, iV;

  NotificationList(
      {this.sId,
      this.id,
      this.message,
      this.title,
      this.type,
      this.senderId,
      this.receiverId,
      this.insertDate,
      this.creationDate,
      this.iV,
      this.senderProfilePic,
      this.senderName});

  NotificationList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    id = json['id'];

    message = json['message'];

    title = json['title'];

    type = json['type'];

    senderId = json['senderId'] != null ? json['senderId'] : "";

    receiverId = json['receiverId'];

    insertDate = json['insertDate'];

    creationDate = json['creationDate'];

    senderProfilePic = json['senderProfilePic'] ?? "";

    iV = json['__v'];

    senderName = json['senderName'];
  }
}
