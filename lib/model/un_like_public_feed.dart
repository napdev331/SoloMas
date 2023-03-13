class UnLikePublicFeedModel {
  int? statusCode;

  String? message, data;

  UnLikePublicFeedModel({this.statusCode, this.message, this.data});

  UnLikePublicFeedModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    data = json['data'];
  }
}
