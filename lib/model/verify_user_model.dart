class VerifyUserModel {
  int? statusCode;

  String? message, data;

  VerifyUserModel({this.statusCode, this.message, this.data});

  VerifyUserModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    data = json['data'];
  }
}
