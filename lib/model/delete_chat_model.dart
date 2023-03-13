import 'package:solomas/helpers/common_helper.dart';

class DeleteChatModel {
  int? statusCode;

  String? message, data;

  DeleteChatModel({this.statusCode, this.message, this.data});

  DeleteChatModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
