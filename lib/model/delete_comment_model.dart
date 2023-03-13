class DeleteCommentModel {
  int? statusCode;
  String? message;
  String? data;

  DeleteCommentModel({this.statusCode, this.message, this.data});

  DeleteCommentModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    data['data'] = this.data;
    return data;
  }
}
