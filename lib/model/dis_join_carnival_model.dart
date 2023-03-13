import 'package:solomas/helpers/common_helper.dart';

class DisJoinCarnivalModel {
  int? statusCode;

  String? message, data;

  DisJoinCarnivalModel({this.statusCode, this.message, this.data});

  DisJoinCarnivalModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
