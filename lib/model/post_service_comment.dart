class PostServiceCommentResponse {
  int? statusCode;
  String? message;
  Data? data;

  PostServiceCommentResponse({this.statusCode, this.message, this.data});

  PostServiceCommentResponse.fromJson(Map<String, dynamic> json) {
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
  String? serviceId;
  String? userId;
  String? comment;
  int? insertDate;
  String? serviceCommentId;
  int? iV;

  Data(
      {this.isNewComment,
      this.isReported,
      this.sId,
      this.serviceId,
      this.userId,
      this.comment,
      this.insertDate,
      this.serviceCommentId,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    isNewComment = json['isNewComment'];
    isReported = json['isReported'];
    sId = json['_id'];
    serviceId = json['serviceId'];
    userId = json['userId'];
    comment = json['comment'];
    insertDate = json['insertDate'];
    serviceCommentId = json['serviceCommentId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isNewComment'] = this.isNewComment;
    data['isReported'] = this.isReported;
    data['_id'] = this.sId;
    data['serviceId'] = this.serviceId;
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['insertDate'] = this.insertDate;
    data['serviceCommentId'] = this.serviceCommentId;
    data['__v'] = this.iV;
    return data;
  }
}
