class CarnivalsReviewList {
  int? statusCode;
  String? message;
  Data? data;

  CarnivalsReviewList({this.statusCode, this.message, this.data});

  CarnivalsReviewList.fromJson(Map<String, dynamic> json) {
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
  List<CarnivalReviewList>? carnivalReviewList;

  Data({this.totalCount, this.carnivalReviewList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['carnivalReviewList'] != null) {
      carnivalReviewList = <CarnivalReviewList>[];
      json['carnivalReviewList'].forEach((v) {
        carnivalReviewList?.add(new CarnivalReviewList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.carnivalReviewList != null) {
      data['carnivalReviewList'] =
          this.carnivalReviewList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CarnivalReviewList {
  String? carnivalId;
  String? userId;
  String? review;
  String? image;
  int? insertDate;
  String? carnivalReviewId;
  String? userName;
  String? userProfilePic;
  String? carnivalTitle;

  CarnivalReviewList(
      {this.carnivalId,
        this.userId,
        this.review,
        this.image,
        this.insertDate,
        this.carnivalReviewId,
        this.userName,
        this.userProfilePic,
        this.carnivalTitle});

  CarnivalReviewList.fromJson(Map<String, dynamic> json) {
    carnivalId = json['carnivalId'];
    userId = json['userId'];
    review = json['review'];
    image = json['image'];
    insertDate = json['insertDate'];
    carnivalReviewId = json['carnivalReviewId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    carnivalTitle = json['carnivalTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['carnivalId'] = this.carnivalId;
    data['userId'] = this.userId;
    data['review'] = this.review;
    data['image'] = this.image;
    data['insertDate'] = this.insertDate;
    data['carnivalReviewId'] = this.carnivalReviewId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['carnivalTitle'] = this.carnivalTitle;
    return data;
  }
}
