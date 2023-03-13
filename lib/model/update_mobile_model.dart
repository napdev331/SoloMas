import 'package:solomas/helpers/common_helper.dart';

class CreateOtpModel {
  String? message, data, error;

  int? statusCode;

  CreateOtpModel({this.message, this.statusCode, this.data, this.error});

  CreateOtpModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];

    statusCode = json['statusCode'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
