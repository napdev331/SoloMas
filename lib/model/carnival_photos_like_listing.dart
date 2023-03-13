class CarnivalPhotosLikeModel {
  int? statusCode;
  String? message;
  Data? data;

  CarnivalPhotosLikeModel({this.statusCode, this.message, this.data});

  CarnivalPhotosLikeModel.fromJson(Map<String, dynamic> json) {
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
  List<CarnivalPhotoLikeList>? carnivalPhotoLikeList;

  Data({this.carnivalPhotoLikeList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['carnivalPhotoLikeList'] != null) {
      carnivalPhotoLikeList = <CarnivalPhotoLikeList>[];
      json['carnivalPhotoLikeList'].forEach((v) {
        carnivalPhotoLikeList?.add(new CarnivalPhotoLikeList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.carnivalPhotoLikeList != null) {
      data['carnivalPhotoLikeList'] =
          this.carnivalPhotoLikeList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CarnivalPhotoLikeList {
  String? userId;
  String? carnivalPhotoLikeId;
  String? userName;
  String? userProfilePic;

  CarnivalPhotoLikeList(
      {this.userId,
        this.carnivalPhotoLikeId,
        this.userName,
        this.userProfilePic});

  CarnivalPhotoLikeList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    carnivalPhotoLikeId = json['carnivalPhotoLikeId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['carnivalPhotoLikeId'] = this.carnivalPhotoLikeId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    return data;
  }
}
