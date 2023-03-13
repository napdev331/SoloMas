class CarnivalPostCommentModel {
  int? statusCode;
  String? message;
  Data? data;

  CarnivalPostCommentModel({this.statusCode, this.message, this.data});

  CarnivalPostCommentModel.fromJson(Map<String, dynamic> json) {
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
  bool? isNewComment;
  bool? isReported;
  String? sId;
  String? carnivalPhotoId;
  String? userId;
  String? comment;
  int? insertDate;
  int? iV;
  String? carnivalPhotoCommentId;

  Data(
      {this.isNewComment,
        this.isReported,
        this.sId,
        this.carnivalPhotoId,
        this.userId,
        this.comment,
        this.insertDate,
        this.iV,
        this.carnivalPhotoCommentId});

  Data.fromJson(Map<String, dynamic> json) {
    isNewComment = json['isNewComment'];
    isReported = json['isReported'];
    sId = json['_id'];
    carnivalPhotoId = json['carnivalPhotoId'];
    userId = json['userId'];
    comment = json['comment'];
    insertDate = json['insertDate'];
    iV = json['__v'];
    carnivalPhotoCommentId = json['carnivalPhotoCommentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isNewComment'] = this.isNewComment;
    data['isReported'] = this.isReported;
    data['_id'] = this.sId;
    data['carnivalPhotoId'] = this.carnivalPhotoId;
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['insertDate'] = this.insertDate;
    data['__v'] = this.iV;
    data['carnivalPhotoCommentId'] = this.carnivalPhotoCommentId;
    return data;
  }
}
