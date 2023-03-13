import 'package:solomas/helpers/common_helper.dart';

class CarnivalCommentListModel {
 
  int? statusCode;
 
  String? message;
 
  Data? data;
  
  CarnivalCommentListModel({this.statusCode, this.message, this.data});
  
  CarnivalCommentListModel.fromJson(Map<String, dynamic> json) {
 
    statusCode = json['statusCode'];
 
    message = json['message'];

    if(statusCode == 200) {
  
      data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  
    } else {
  
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  
  List<CarnivalCommentsList>? carnivalCommentsList;
  
  Data({this.carnivalCommentsList});
  
  Data.fromJson(Map<String, dynamic> json) {
  
    if (json['carnivalCommentsList'] != null) {
  
      carnivalCommentsList =  <CarnivalCommentsList>[];
  
      json['carnivalCommentsList'].forEach((v) {
  
        carnivalCommentsList?.add(new CarnivalCommentsList.fromJson(v));
      });
    }
  }
}

class CarnivalCommentsList {
  
  String? comment, carnivalCommentId, userName, userProfilePic, userId;
  
  int? insertDate;
  
  List<ReplyData>? replyData;
  
  bool? showReplies;
  
  CarnivalCommentsList({this.comment, this.insertDate, this.carnivalCommentId,
        this.userName, this.userProfilePic, this.replyData, this.showReplies, this.userId});
  
  CarnivalCommentsList.fromJson(Map<String, dynamic> json) {
   
    comment = json['comment'];
   
    insertDate = json['insertDate'];
   
    carnivalCommentId = json['carnivalCommentId'];
   
    userName = json['userName'];
   
    userProfilePic = json['userProfilePic'];

    userId = json['userId'];
   
    if (json['replyData'] != null) {
   
      replyData = <ReplyData>[];
   
      json['replyData'].forEach((v) {
   
        replyData?.add(ReplyData.fromJson(v));
      });
    }

    showReplies = false;
  }
}

class ReplyData {
  
  String? comment, userId, userName, userProfilePic,replyCommentId;
  
  int? insertDate;
  
  ReplyData({this.comment, this.insertDate, this.userId, this.userName, this.userProfilePic,this.replyCommentId});
  
  ReplyData.fromJson(Map<String, dynamic> json) {
   
    comment = json['comment'];
   
    insertDate = json['insertDate'];
   
    userId = json['userId'];
 
    userName = json['userName'];
   
    userProfilePic = json['userProfilePic'];

    replyCommentId = json['replyCommentId'];
  }
}