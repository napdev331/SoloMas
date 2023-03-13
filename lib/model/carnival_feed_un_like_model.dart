class CarnivalFeedUnLikeModel {
  int? statusCode;

  String? message, data;

  CarnivalFeedUnLikeModel({this.statusCode, this.message, this.data});

  CarnivalFeedUnLikeModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    data = json['data'];
  }
}
