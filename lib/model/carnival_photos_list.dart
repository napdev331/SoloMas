class CarnivalPhotosList {
  int? statusCode;
  String? message;
  Data? data;

  CarnivalPhotosList({this.statusCode, this.message, this.data});

  CarnivalPhotosList.fromJson(Map<String, dynamic> json) {
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
  int? totalCount;
  List<CarnivalPhotoList>? carnivalPhotoList;

  Data({this.totalCount, this.carnivalPhotoList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['carnivalPhotoList'] != null) {
      carnivalPhotoList = <CarnivalPhotoList>[];
      json['carnivalPhotoList'].forEach((v) {
        carnivalPhotoList?.add(new CarnivalPhotoList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.carnivalPhotoList != null) {
      data['carnivalPhotoList'] =
          this.carnivalPhotoList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CarnivalPhotoList {
  String? carnivalId;
  String? userId;
  List<String>? images;
  int? totalComments;
  int? totalLikes;
  int? insertDate;
  String? carnivalPhotoId;
  bool? isCarnivalPhotoReportedByMe;
  bool? isLike;
  String? userName;
  String? userProfilePic;
  String? carnivalTitle;
  int? sliderPosition;

  CarnivalPhotoList(
      {this.carnivalId,
        this.userId,
        this.images,
        this.totalComments,
        this.totalLikes,
        this.insertDate,
        this.carnivalPhotoId,
        this.isCarnivalPhotoReportedByMe,
        this.isLike,
        this.userName,
        this.userProfilePic,
        this.carnivalTitle,
      this.sliderPosition});

  CarnivalPhotoList.fromJson(Map<String, dynamic> json) {
    carnivalId = json['carnivalId'];
    userId = json['userId'];
    images = json['images'].cast<String>();
    totalComments = json['totalComments'];
    totalLikes = json['totalLikes'];
    insertDate = json['insertDate'];
    carnivalPhotoId = json['carnivalPhotoId'];
    isCarnivalPhotoReportedByMe = json['isCarnivalPhotoReportedByMe'];
    isLike = json['isLike'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    carnivalTitle = json['carnivalTitle'];
    sliderPosition=0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['carnivalId'] = this.carnivalId;
    data['userId'] = this.userId;
    data['images'] = this.images;
    data['totalComments'] = this.totalComments;
    data['totalLikes'] = this.totalLikes;
    data['insertDate'] = this.insertDate;
    data['carnivalPhotoId'] = this.carnivalPhotoId;
    data['isCarnivalPhotoReportedByMe'] = this.isCarnivalPhotoReportedByMe;
    data['isLike'] = this.isLike;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['carnivalTitle'] = this.carnivalTitle;
    return data;
  }
}
