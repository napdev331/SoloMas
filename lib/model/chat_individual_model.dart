import 'package:solomas/helpers/common_helper.dart';

class ChatIndividualModel {
  int? statusCode;

  String? message;

  Data? data;

  ChatIndividualModel({this.statusCode, this.message, this.data});

  ChatIndividualModel.fromJson(Map<String, dynamic> json) {
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
  List<ChatList>? chatList;

  CurrentUser? currentUser;

  ChatUser? chatUser;

  Data({this.chatList, this.currentUser, this.chatUser});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['chatList'] != null) {
      chatList = <ChatList>[];

      json['chatList'].forEach((v) {
        chatList?.add(new ChatList.fromJson(v));
      });
    }

    currentUser = json['currentUser'] != null
        ? CurrentUser.fromJson(json['currentUser'])
        : null;

    chatUser =
        json['chatUser'] != null ? ChatUser.fromJson(json['chatUser']) : null;
  }
}

class ChatList {
  String? sId,
      senderId,
      receiverId,
      message,
      type,
      additionalData,
      readAt,
      conversationId,
      deliveredAt;

  bool? isRead, isDelivered, isOwnMessage;

  int? sentAt;

  ChatList(
      {this.sId,
      this.isRead,
      this.isDelivered,
      this.senderId,
      this.receiverId,
      this.sentAt,
      this.message,
      this.type,
      this.additionalData,
      this.conversationId,
      this.deliveredAt,
      this.isOwnMessage,
      this.readAt});

  ChatList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    isRead = json['isRead'];

    isDelivered = json['isDelivered'];

    senderId = json['senderId'];

    receiverId = json['receiverId'];

    sentAt = json['sentAt'];

    message = json['message'];

    type = json['type'];

    additionalData = json['additionalData'];

    conversationId = json['conversationId'];

    deliveredAt = json['deliveredAt'];

    isOwnMessage = json['isOwnMessage'];

    readAt = json['readAt'];
  }
}

class CurrentUser {
  String? profilePic, sId;

  CurrentUser({this.profilePic, this.sId});

  CurrentUser.fromJson(Map<String, dynamic> json) {
    profilePic = json['profilePic'];

    sId = json['_id'];
  }
}

class ChatUser {
  String? sId, userId;

  bool? blockByReceiver, blockByYou;

  ChatUser({this.sId, this.userId, this.blockByReceiver, this.blockByYou});

  ChatUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    userId = json['userId'];

    blockByReceiver = json['blockByReceiver'];

    blockByYou = json['blockByYou'];
  }
}
