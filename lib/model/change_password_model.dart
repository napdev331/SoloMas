import 'package:solomas/helpers/common_helper.dart';

class ChangedPasswordModel {
  
  int? statusCode;
  
  String? message;
  
  String? data;
  
  ChangedPasswordModel({this.statusCode, this.message, this.data});
  
  ChangedPasswordModel.fromJson(Map<String, dynamic> json) {
    
    statusCode = json['statusCode'];
    
    message = json['message'];
    
    if(statusCode == 200) {
      
      data = json['data'];
      
    } else {
  
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}