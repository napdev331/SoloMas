import 'package:solomas/helpers/common_helper.dart';

class UploadImageModel {
  int? statusCode;

  String? message;

  Datum? data;

  UploadImageModel({this.statusCode, this.message, this.data});

  UploadImageModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? Datum.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(
          statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Datum {
  String? url;
  String? coverUrl;

  Datum({this.url, this.coverUrl});

  Datum.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    coverUrl = json['coverUrl'];
  }
}
