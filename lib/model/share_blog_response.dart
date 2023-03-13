class ShareBlogResponse {
  int? statusCode;
  String? message;
  Data? data;

  ShareBlogResponse({this.statusCode, this.message, this.data});

  ShareBlogResponse.fromJson(Map<String, dynamic> json) {
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
  int? totalComments;
  bool? isReported;
  int? reportCount;
  int? shareCount;
  String? sId;
  String? userId;
  String? image;
  String? date;
  String? title;
  String? body;
  int? insertDate;
  String? creationDate;
  int? iV;

  Data(
      {this.totalComments,
      this.isReported,
      this.reportCount,
      this.shareCount,
      this.sId,
      this.userId,
      this.image,
      this.date,
      this.title,
      this.body,
      this.insertDate,
      this.creationDate,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    totalComments = json['totalComments'];
    isReported = json['isReported'];
    reportCount = json['reportCount'];
    shareCount = json['shareCount'];
    sId = json['_id'];
    userId = json['userId'];
    image = json['image'];
    date = json['date'];
    title = json['title'];
    body = json['body'];
    insertDate = json['insertDate'];
    creationDate = json['creationDate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalComments'] = this.totalComments;
    data['isReported'] = this.isReported;
    data['reportCount'] = this.reportCount;
    data['shareCount'] = this.shareCount;
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['image'] = this.image;
    data['date'] = this.date;
    data['title'] = this.title;
    data['body'] = this.body;
    data['insertDate'] = this.insertDate;
    data['creationDate'] = this.creationDate;
    data['__v'] = this.iV;
    return data;
  }
}
