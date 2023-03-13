// To parse this JSON data, do
//
//     final userLocationUpdateModel = userLocationUpdateModelFromJson(jsonString);

import 'dart:convert';

UserLocationUpdateModel userLocationUpdateModelFromJson(String str) =>
    UserLocationUpdateModel.fromJson(json.decode(str));

String userLocationUpdateModelToJson(UserLocationUpdateModel data) =>
    json.encode(data.toJson());

class UserLocationUpdateModel {
  UserLocationUpdateModel({
    this.statusCode,
    this.message,
    this.data,
  });

  int? statusCode;
  String? message;
  String? data;

  factory UserLocationUpdateModel.fromJson(Map<String, dynamic> json) =>
      UserLocationUpdateModel(
        statusCode: json["statusCode"] == null ? null : json["statusCode"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : json["data"],
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode == null ? null : statusCode,
        "message": message == null ? null : message,
        "data": data == null ? null : data,
      };
}
