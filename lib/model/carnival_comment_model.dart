import 'package:solomas/helpers/common_helper.dart';

class CarnivalCommentModel {
  
  int? statusCode;
  
  String? message;
  
  Data? data;
  
  CarnivalCommentModel({this.statusCode, this.message, this.data});
  
  CarnivalCommentModel.fromJson(Map<String, dynamic> json) {
  
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
  
  bool? isNewComment, isReported;
  
  String? sId, carnivalFeedId, userId, comment;
  
  int? insertDate, iV;
  
  Data({this.isNewComment, this.isReported, this.sId, this.carnivalFeedId,
        this.userId, this.comment, this.insertDate, this.iV});
  
  Data.fromJson(Map<String, dynamic> json) {
   
    isNewComment = json['isNewComment'];
   
    isReported = json['isReported'];
   
    sId = json['_id'];
   
    carnivalFeedId = json['carnivalFeedId'];
   
    userId = json['userId'];
   
    comment = json['comment'];
   
    insertDate = json['insertDate'];
   
    iV = json['__v'];
  }
}