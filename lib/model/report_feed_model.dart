import 'package:solomas/helpers/common_helper.dart';

class ReportFeedModel {
  int? statusCode;

  String? message, data;

  ReportFeedModel({this.statusCode, this.message, this.data});

  ReportFeedModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
