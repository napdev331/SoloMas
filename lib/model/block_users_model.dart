import 'package:solomas/helpers/common_helper.dart';

class BlockedUserModel {
  
  int? statusCode;
  
  String? message;
  
  Data? data;
  
  BlockedUserModel({this.statusCode, this.message, this.data});
  
  BlockedUserModel.fromJson(Map<String, dynamic> json) {
   
    statusCode = json['statusCode'];
   
    message = json['message'];

    if(statusCode == 200) {
  
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
  
    } else {
  
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
 
  List<BlockedUser>? blockedUser;
  
  Data({this.blockedUser});
  
  Data.fromJson(Map<String, dynamic> json) {
 
    if (json['blockedUser'] != null) {
 
      blockedUser =  <BlockedUser>[];
 
      json['blockedUser'].forEach((v) {
 
        blockedUser?.add(new BlockedUser.fromJson(v));
      });
    }
  }
}

class BlockedUser {
 
  String? blockUserId, userProfilePic, userName, userBand;
 
  BlockedUser({this.blockUserId, this.userName, this.userProfilePic, this.userBand});
  
  BlockedUser.fromJson(Map<String, dynamic> json) {
   
    blockUserId = json['blockUserId'];
   
    userName = json['userName'];
   
    userProfilePic = json['userProfilePic'];

    userBand = json['userBand'];
  }
}