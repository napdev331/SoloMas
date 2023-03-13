import 'package:solomas/helpers/common_helper.dart';

class CarnivalLikeListModel {
  
  int? statusCode;
  
  String? message;
  
  Data? data;
  
  CarnivalLikeListModel({this.statusCode, this.message, this.data});
  
  CarnivalLikeListModel.fromJson(Map<String, dynamic> json) {
  
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
  
  List<CarnivalLikeList>? carnivalLikeList;
  
  Data({this.carnivalLikeList});
  
  Data.fromJson(Map<String, dynamic> json) {
   
    if (json['carnivalLikeList'] != null) {
   
      carnivalLikeList =  <CarnivalLikeList>[];
   
      json['carnivalLikeList'].forEach((v) {
   
        carnivalLikeList?.add(new CarnivalLikeList.fromJson(v));
      });
    }
  }
}

class CarnivalLikeList {
  
  String? carnivalLikeId, userName, userProfilePic, userId;

  CarnivalLikeList({this.carnivalLikeId, this.userName, this.userProfilePic, this.userId});
  
  CarnivalLikeList.fromJson(Map<String, dynamic> json) {
   
    carnivalLikeId = json['carnivalLikeId'];
   
    userName = json['userName'];
   
    userProfilePic = json['userProfilePic'];

    userId = json['userId'];
  }
}