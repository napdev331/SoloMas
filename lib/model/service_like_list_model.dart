class ServiceLikeListModel {
  int? statusCode;
  String? message;
  Data? data;

  ServiceLikeListModel({this.statusCode, this.message, this.data});

  ServiceLikeListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  List<ServiceLikeList>? serviceLikeList;

  Data({this.serviceLikeList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['serviceLikeList'] != null) {
      serviceLikeList = <ServiceLikeList>[];
      json['serviceLikeList'].forEach((v) {
        serviceLikeList?.add(new ServiceLikeList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.serviceLikeList != null) {
      data['serviceLikeList'] =
          this.serviceLikeList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceLikeList {
  String? userId;
  String? serviceLikeId;
  String? userName;
  String? userProfilePic;

  ServiceLikeList(
      {this.userId, this.serviceLikeId, this.userName, this.userProfilePic});

  ServiceLikeList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    serviceLikeId = json['serviceLikeId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['serviceLikeId'] = this.serviceLikeId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    return data;
  }
}
