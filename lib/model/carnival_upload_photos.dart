class CreatePhotosCarnivalModel {
  int? statusCode;
  String? message;
  Data? data;

  CreatePhotosCarnivalModel({this.statusCode, this.message, this.data});

  CreatePhotosCarnivalModel.fromJson(Map<String, dynamic> json) {
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
  CarnivalPhoto? carnivalPhoto;
  String? message;



  Data({this.carnivalPhoto,this.message});

  Data.fromJson(Map<String, dynamic> json) {
    carnivalPhoto = json['carnivalPhoto'] != null
        ? new CarnivalPhoto.fromJson(json['carnivalPhoto'])
        : null;
    message = json['message'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.carnivalPhoto != null) {
      data['carnivalPhoto'] = this.carnivalPhoto?.toJson();
    }
    return data;
  }
}

class CarnivalPhoto {
  String? carnivalId;
  String? userId;
  List<String>? images;
  bool? isReported;
  int? reportCount;
  int? totalComments;
  int? totalLikes;
  String? sId;
  String? creationDate;
  int? insertDate;
  int? iV;
  String? carnivalPhotoId;

  CarnivalPhoto(
      {this.carnivalId,
        this.userId,
        this.images,
        this.isReported,
        this.reportCount,
        this.totalComments,
        this.totalLikes,
        this.sId,
        this.creationDate,
        this.insertDate,
        this.iV,
        this.carnivalPhotoId});

  CarnivalPhoto.fromJson(Map<String, dynamic> json) {
    carnivalId = json['carnivalId'];
    userId = json['userId'];
    images = json['images'].cast<String>();
    isReported = json['isReported'];
    reportCount = json['reportCount'];
    totalComments = json['totalComments'];
    totalLikes = json['totalLikes'];
    sId = json['_id'];
    creationDate = json['creationDate'];
    insertDate = json['insertDate'];
    iV = json['__v'];
    carnivalPhotoId = json['carnivalPhotoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['carnivalId'] = this.carnivalId;
    data['userId'] = this.userId;
    data['images'] = this.images;
    data['isReported'] = this.isReported;
    data['reportCount'] = this.reportCount;
    data['totalComments'] = this.totalComments;
    data['totalLikes'] = this.totalLikes;
    data['_id'] = this.sId;
    data['creationDate'] = this.creationDate;
    data['insertDate'] = this.insertDate;
    data['__v'] = this.iV;
    data['carnivalPhotoId'] = this.carnivalPhotoId;
    return data;
  }
}
