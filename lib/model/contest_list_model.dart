import 'package:solomas/helpers/common_helper.dart';

class ContestListModel {
  int? statusCode;

  String? message;

  Data? data;

  ContestListModel({this.statusCode, this.message, this.data});

  ContestListModel.fromJson(Map<String, dynamic> json) {
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
  List<ContestList>? contestList;

  Data({this.contestList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['contestList'] != null) {
      contestList = <ContestList>[];

      json['contestList'].forEach((v) {
        contestList?.add(new ContestList.fromJson(v));
      });
    }
  }
}

class ContestList {
  Location? location;

  String? locationName,
      carnivalId,
      title,
      description,
      coverImageUrl,
      creationDate,
      contestId,
      type,
      startDateString,
      endDateString;

  int? startDate, endDate, insertDate;

  bool? contestJoined;

  ContestList(
      {this.location,
      this.locationName,
      this.carnivalId,
      this.title,
      this.description,
      this.coverImageUrl,
      this.startDate,
      this.endDate,
      this.creationDate,
      this.insertDate,
      this.contestId,
      this.contestJoined,
      this.type,
      this.startDateString,
      this.endDateString});

  ContestList.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;

    locationName = json['locationName'];

    carnivalId = json['carnivalId'];

    title = json['title'];

    description = json['description'];

    coverImageUrl = json['coverImageUrl'];

    startDate = json['startDate'];

    endDate = json['endDate'];

    creationDate = json['creationDate'];

    insertDate = json['insertDate'];

    contestId = json['contestId'];

    contestJoined = json['contestJoined'];

    type = json['type'];

    startDateString = json['startDateString'];

    endDateString = json['endDateString'];
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
