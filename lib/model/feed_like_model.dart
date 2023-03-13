
class FeedLikeModel {
  int? statusCode;

  String? message;

  Data? data;

  FeedLikeModel({this.statusCode, this.message, this.data});

  FeedLikeModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  String? sId, publicFeedId, userId;

  int? insertDate, iV;

  Data({this.sId, this.publicFeedId, this.userId, this.insertDate, this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    publicFeedId = json['publicFeedId'];

    userId = json['userId'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
