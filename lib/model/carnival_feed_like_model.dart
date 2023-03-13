class CarnivalFeedLikeModel {
  int? statusCode;

  String? message;

  Data? data;

  CarnivalFeedLikeModel({this.statusCode, this.message, this.data});

  CarnivalFeedLikeModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }
}

class Data {
  String? sId, carnivalFeedId, userId;

  int? insertDate, iV;

  Data({this.sId, this.carnivalFeedId, this.userId, this.insertDate, this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    carnivalFeedId = json['carnivalFeedId'];

    userId = json['userId'];

    insertDate = json['insertDate'];

    iV = json['__v'];
  }
}
