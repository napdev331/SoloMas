import 'package:solomas/helpers/common_helper.dart';

class DeletePublicFeedModel {
  int? statusCode;

  String? message, data;

  DeletePublicFeedModel({this.statusCode, this.message, this.data});

  DeletePublicFeedModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
