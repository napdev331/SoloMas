import 'package:solomas/helpers/common_helper.dart';

class SocialLoginModel {
  int? statusCode;

  String? message;

  Data? data;

  SocialLoginModel({this.statusCode, this.message, this.data});

  SocialLoginModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
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
      gender,
      profilePic,
      userType,
      locationName,
      referralCode;

  int? age, insertDate;

  Location? location;

  bool? isNewUser;

  AddressData? address;

  Data(
      {this.userId,
      this.fullName,
      this.mobile,
      this.email,
      this.status,
      this.age,
      this.gender,
      this.profilePic,
      this.userType,
      this.insertDate,
      this.locationName,
      this.location,
      this.isNewUser,
      this.address,
      this.referralCode});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];

    fullName = json['fullName'];

    mobile = json['mobile'];

    email = json['email'];

    status = json['status'];

    age = json['age'];

    gender = json['gender'];

    profilePic = json['profilePic'];

    userType = json['userType'];

    insertDate = json['insertDate'];

    locationName = json['locationName'];

    referralCode = json['referralCode'];

    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;

    isNewUser = json['isNewUser'];

    address = json['address'] != null
        ? new AddressData.fromJson(json['address'])
        : null;
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

class AddressData {
  String? name, street, email, state, city, phoneNumber;

  AddressData(
      {this.name,
      this.street,
      this.email,
      this.phoneNumber,
      this.state,
      this.city});

  AddressData.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    street = json['street'];

    email = json['email'];

    phoneNumber = json['phoneNumber'];

    state = json['state'];

    city = json['city'];
  }
}
