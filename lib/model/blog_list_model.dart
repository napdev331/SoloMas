class BlogListResponse {
  int? statusCode;
  String? message;
  Data? data;

  BlogListResponse({this.statusCode, this.message, this.data});

  BlogListResponse.fromJson(Map<String, dynamic> json) {
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
  List<BlogList>? blogList;

  Data({this.totalCount, this.blogList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['blogList'] != null) {
      blogList = <BlogList>[];
      json['blogList'].forEach((v) {
        blogList?.add(new BlogList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.blogList != null) {
      data['blogList'] = this.blogList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BlogList {
  int? totalComments;
  bool? isReported;
  int? reportCount;
  String? userId;
  String? image;
  String? date;
  String? title;
  String? body;
  int? insertDate;
  int? shareCount;
  String? blogId;
  bool? isLike;
  int? totalLikes;

  BlogList(
      {this.totalComments,
      this.isReported,
      this.reportCount,
      this.userId,
      this.image,
      this.date,
      this.title,
      this.body,
      this.insertDate,
      this.shareCount,
      this.blogId,
      this.isLike,
      this.totalLikes});

  BlogList.fromJson(Map<String, dynamic> json) {
    totalComments = json['totalComments'];
    isReported = json['isReported'];
    reportCount = json['reportCount'];
    userId = json['userId'];
    image = json['image'];
    date = json['date'];
    title = json['title'];
    body = json['body'];
    insertDate = json['insertDate'];
    shareCount = json['shareCount'];
    blogId = json['blogId'];
    isLike = json['isLike'];
    totalLikes = json['totalLikes'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalComments'] = this.totalComments;
    data['isReported'] = this.isReported;
    data['reportCount'] = this.reportCount;
    data['userId'] = this.userId;
    data['image'] = this.image;
    data['date'] = this.date;
    data['title'] = this.title;
    data['body'] = this.body;
    data['insertDate'] = this.insertDate;
    data['shareCount'] = this.shareCount;
    data['blogId'] = this.blogId;
    data['isLike'] = this.isLike;
    data['totalLikes'] = this.totalLikes;
    return data;
  }
}
