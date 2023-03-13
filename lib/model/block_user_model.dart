import 'package:solomas/helpers/common_helper.dart';

class BlockUserModel {
  
  int? statusCode;
  
  String? message;
  
  String? data;
  
  BlockUserModel({this.statusCode, this.message, this.data});
  
  BlockUserModel.fromJson(Map<String, dynamic> json) {
  
    statusCode = json['statusCode'];
  
    message = json['message'];

    if(statusCode == 200) {
  
      data = json['data'];

    } else {

      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}