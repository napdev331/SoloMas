import 'package:solomas/helpers/common_helper.dart';

class SearchUserModel {
  int? statusCode;

  String? message;

  List<Data>? data;

  SearchUserModel({this.statusCode, this.message, this.data});

  SearchUserModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      if (json['data'] != null) {
        data = <Data>[];

        json['data'].forEach((v) {
          data?.add(Data.fromJson(v));
        });
      }
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  Location? location;

  String? fullName,
      mobile,
      email,
      profilePic,
      userType,
      status,
      locationName,
      userId,
      band;

  int? totalServices, totalFavorites, insertDate;

  Data(
      {this.location,
      this.fullName,
      this.mobile,
      this.email,
      this.profilePic,
      this.totalServices,
      this.totalFavorites,
      this.userType,
      this.insertDate,
      this.status,
      this.locationName,
      this.userId,
      this.band});

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;

    fullName = json['fullName'];

    mobile = json['mobile'];

    email = json['email'];

    profilePic = json['profilePic'];

    totalServices = json['totalServices'];

    totalFavorites = json['totalFavorites'];

    userType = json['userType'];

    insertDate = json['insertDate'];

    status = json['status'];

    locationName = json['locationName'];

    userId = json['userId'];

    band = json['band'] ?? "";
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
