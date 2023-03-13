import 'package:solomas/helpers/common_helper.dart';

class VerifyOtpModel {
  int? statusCode;

  String? message;

  Data? data;

  VerifyOtpModel({this.statusCode, this.message, this.data});

  VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  int? token;

  String? type;

  Data({this.token, this.type});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];

    type = json['type'];
  }
}
