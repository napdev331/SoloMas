import 'package:solomas/helpers/common_helper.dart';

class GetPeoplesModel {
  int? statusCode;

  String? message;

  List<GroupDataList>? data;

  GetPeoplesModel({this.statusCode, this.message, this.data});

  GetPeoplesModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      if (json['data'] != null) {
        data = <GroupDataList>[];

        json['data'].forEach((v) {
          data?.add(GroupDataList.fromJson(v));
        });
      }
    } else {
      CommonHelper.checkStatusCode(
          statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class GroupDataList {
  Locations? location;

  String? fullName,
      mobile,
      email,
      profilePic,
      userType,
      gender,
      status,
      locationName,
      coverImage,
      userId;

  int? age, insertDate;

  GroupDataList(
      {this.location,
      this.fullName,
      this.mobile,
      this.email,
      this.profilePic,
      this.userType,
      this.age,
      this.gender,
      this.insertDate,
      this.status,
      this.locationName,
      this.coverImage,
      this.userId});

  GroupDataList.fromJson(Map<String, dynamic> json) {
    location =
        json['location'] != null ? Locations.fromJson(json['location']) : null;

    fullName = json['fullName'];

    mobile = json['mobile'];

    email = json['email'];

    profilePic = json['profilePic'];

    userType = json['userType'];

    age = json['age'];

    gender = json['gender'];

    insertDate = json['insertDate'];

    status = json['status'];

    locationName = json['locationName'];

    coverImage = json['coverImage'];

    userId = json['userId'];
  }
}

class Locations {
  double? lat, lng;

  Locations({this.lat, this.lng});

  Locations.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];

    lng = json['lng'];
  }
}
