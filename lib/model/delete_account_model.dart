import 'package:solomas/helpers/common_helper.dart';

class DeleteAccountModel {
  int? statusCode;

  String? status, data;

  DeleteAccountModel({this.statusCode, this.status, this.data});

  DeleteAccountModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    status = json['status'];

    if (statusCode == 200) {
      data = json['data'];
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}
