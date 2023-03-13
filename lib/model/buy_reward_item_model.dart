import 'package:solomas/helpers/common_helper.dart';

class BuyRewardItemModel {

  int? statusCode;

  String? message;

  Data? data;

  BuyRewardItemModel({this.statusCode, this.message, this.data});

  BuyRewardItemModel.fromJson(Map<String, dynamic> json) {

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

  String? status, sId, rewardItemId, userId, creationDate;

  int? insertDate, iV;

  Data({this.status, this.sId, this.rewardItemId, this.userId, this.creationDate, this.insertDate, this.iV});

  Data.fromJson(Map<String, dynamic> json) {

    status = json['status'];

    sId = json['_id'];

    rewardItemId = json['rewardItemId'];

    userId = json['userId'];

    creationDate = json['creationDate'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}