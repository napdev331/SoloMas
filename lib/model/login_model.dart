import 'package:solomas/helpers/common_helper.dart';

class LoginModel {
  int? statusCode;

  String? message;

  Data? data;

  LoginModel({this.statusCode, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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

  Address? address;

  Data(
      {this.userId,
      this.fullName,
      this.mobile,
      this.email,
      this.status,
      this.gender,
      this.age,
      this.profilePic,
      this.userType,
      this.insertDate,
      this.locationName,
      this.location,
      this.address,
      this.referralCode});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];

    fullName = json['fullName'];

    mobile = json['mobile'];

    email = json['email'];

    status = json['status'];

    gender = json['gender'];

    age = json['age'];

    profilePic = json['profilePic'];

    userType = json['userType'];

    insertDate = json['insertDate'];

    locationName = json['locationName'];

    referralCode = json['referralCode'];

    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;

    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
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

class Address {
  String? name, street, email, state, city, phoneNumber;

  Address(
      {this.name,
      this.street,
      this.email,
      this.phoneNumber,
      this.state,
      this.city});

  Address.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    street = json['street'];

    email = json['email'];

    phoneNumber = json['phoneNumber'];

    state = json['state'];

    city = json['city'];
  }
}
