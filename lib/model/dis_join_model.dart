import 'package:solomas/helpers/common_helper.dart';

class DisJoinGroupModel {
  int? statusCode;

  String? message, data;

  DisJoinGroupModel({this.statusCode, this.message, this.data});

  DisJoinGroupModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
