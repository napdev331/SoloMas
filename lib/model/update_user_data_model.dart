import 'package:solomas/helpers/common_helper.dart';

class UpdateUserModel {
  int? statusCode;

  String? message;

  Data? data;

  UpdateUserModel({this.statusCode, this.message, this.data});

  UpdateUserModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  String? userId,
      fullName,
      mobile,
      email,
      status,
      profilePic,
      coverImage,
      gender,
      userType,
      locationName;

  int? age, insertDate;

  Location? location;

  Data(
      {this.userId,
      this.fullName,
      this.mobile,
      this.email,
      this.status,
      this.profilePic,
      this.coverImage,
      this.age,
      this.gender,
      this.userType,
      this.insertDate,
      this.location,
      this.locationName});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];

    fullName = json['fullName'];

    mobile = json['mobile'] ?? "";

    email = json['email'];

    status = json['status'];

    profilePic = json['profilePic'];

    coverImage = json['coverImage'];

    age = json['age'];

    gender = json['gender'];

    userType = json['userType'];

    insertDate = json['insertDate'];

    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    locationName = json['locationName'];
  }
}

class Location {
  double? lat, lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];

    lng = json['lng'];
  }
}
