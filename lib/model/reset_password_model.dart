import 'package:solomas/helpers/common_helper.dart';

class ResetPasswordModel {
  int? statusCode;

  String? message;

  String? data;

  ResetPasswordModel({this.statusCode, this.message, this.data});

  ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
