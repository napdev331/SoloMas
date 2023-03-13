class ReviewResponse {
  int? statusCode;
  String? message;
  Data? data;

  ReviewResponse({this.statusCode, this.message, this.data});

  ReviewResponse.fromJson(Map<String, dynamic> json) {
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
  List<ReviewList>? reviewList;

  Data({this.totalCount, this.reviewList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['reviewList'] != null) {
      reviewList = <ReviewList>[];
      json['reviewList'].forEach((v) {
        reviewList?.add(new ReviewList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.reviewList != null) {
      data['reviewList'] = this.reviewList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReviewList {
  String? eventId;
  String? eventCreatorId;
  String? userId;
  String? review;
  String? creationDate;
  int? insertDate;
  int? iV;
  String? userName;
  String? userProfilePic;
  String? eventTitle;
  String? eventImage;
  String? reviewId;

  ReviewList(
      {this.eventId,
      this.eventCreatorId,
      this.userId,
      this.review,
      this.creationDate,
      this.insertDate,
      this.iV,
      this.userName,
      this.userProfilePic,
      this.eventTitle,
      this.eventImage,
      this.reviewId});

  ReviewList.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventCreatorId = json['eventCreatorId'];
    userId = json['userId'];
    review = json['review'];
    creationDate = json['creationDate'];
    insertDate = json['insertDate'];
    iV = json['__v'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    eventTitle = json['eventTitle'];
    eventImage = json['eventImage'];
    reviewId = json['reviewId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['eventCreatorId'] = this.eventCreatorId;
    data['userId'] = this.userId;
    data['review'] = this.review;
    data['creationDate'] = this.creationDate;
    data['insertDate'] = this.insertDate;
    data['__v'] = this.iV;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['eventTitle'] = this.eventTitle;
    data['eventImage'] = this.eventImage;
    data['reviewId'] = this.reviewId;
    return data;
  }
}
