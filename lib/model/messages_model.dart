import 'package:solomas/helpers/common_helper.dart';

class MessagesModel {
  int? statusCode;

  String? message;

  Data? data;

  MessagesModel({this.statusCode, this.message, this.data});

  MessagesModel.fromJson(Map<String, dynamic> json) {
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
  List<ChatSummaryList>? chatSummaryList;

  Data({this.chatSummaryList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['chatSummaryList'] != null) {
      chatSummaryList = <ChatSummaryList>[];

      json['chatSummaryList'].forEach((v) {
        chatSummaryList?.add(new ChatSummaryList.fromJson(v));
      });
    }
  }
}

class ChatSummaryList {
  String? sId,
      senderId,
      receiverId,
      message,
      readAt,
      deliveredAt,
      conversationId,
      senderFullName,
      receiverProfilePic,
      receiverFullName,
      senderProfilePic;

  int? sentAt, unReadCount;

  bool? isRead, isDelivered, blockByYou;

  ChatSummaryList(
      {this.sId,
      this.senderId,
      this.receiverId,
      this.message,
      this.sentAt,
      this.isRead,
      this.readAt,
      this.isDelivered,
      this.deliveredAt,
      this.unReadCount,
      this.conversationId,
      this.blockByYou,
      this.senderFullName,
      this.receiverProfilePic,
      this.receiverFullName,
      this.senderProfilePic});

  ChatSummaryList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    senderId = json['senderId'];

    receiverId = json['receiverId'];

    message = json['message'];

    sentAt = json['sentAt'];

    isRead = json['isRead'];

    readAt = json['readAt'];

    isDelivered = json['isDelivered'];

    deliveredAt = json['deliveredAt'];

    unReadCount = json['unReadCount'];

    conversationId = json['conversationId'];

    blockByYou = json['blockByYou'];

    senderFullName = json['senderFullName'];

    senderProfilePic = json['senderProfilePic'];

    receiverFullName = json['receiverFullName'];

    receiverProfilePic = json['receiverProfilePic'];
  }
}
