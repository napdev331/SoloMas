import 'package:solomas/helpers/common_helper.dart';

class CheckInCarnivalModel {
  int? statusCode;

  String? message, data;

  CheckInCarnivalModel({this.statusCode, this.message, this.data});

  CheckInCarnivalModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
