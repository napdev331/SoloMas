import 'package:solomas/helpers/common_helper.dart';

class RewardItemModel {
  int? statusCode;

  String? message;

  Data? data;

  RewardItemModel({this.statusCode, this.message, this.data});

  RewardItemModel.fromJson(Map<String, dynamic> json) {
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
  List<RewardItem>? rewardItem;

  String? statusTitle;

  int? totalRewardPoint, totalStatusPoint;

  Data(
      {this.rewardItem,
      this.totalRewardPoint,
      this.totalStatusPoint,
      this.statusTitle});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['rewardItem'] != null) {
      rewardItem = <RewardItem>[];

      json['rewardItem'].forEach((v) {
        rewardItem?.add(RewardItem.fromJson(v));
      });
    }

    totalRewardPoint = json['totalRewardPoint'];

    totalStatusPoint = json['totalStatusPoint'];

    statusTitle = json['statusTitle'];
  }
}

class RewardItem {
  String? sId, icon, name;

  int? pricePoint, insertDate;

  bool? isUnlock;

  RewardItem(
      {this.sId,
      this.icon,
      this.name,
      this.pricePoint,
      this.insertDate,
      this.isUnlock});

  RewardItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    icon = json['icon'];

    name = json['name'];

    pricePoint = json['pricePoint'];

    insertDate = json['insertDate'];

    isUnlock = json['isUnlock'];
  }
}
