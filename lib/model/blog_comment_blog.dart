class BlogCommentResponse {
  int? statusCode;
  String? message;
  Data? data;

  BlogCommentResponse({this.statusCode, this.message, this.data});

  BlogCommentResponse.fromJson(Map<String, dynamic> json) {
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
  List<BlogCommentsList>? blogCommentsList;

  Data({this.totalCount, this.blogCommentsList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['blogCommentsList'] != null) {
      blogCommentsList =  <BlogCommentsList>[];
      json['blogCommentsList'].forEach((v) {
        blogCommentsList?.add(new BlogCommentsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.blogCommentsList != null) {
      data['blogCommentsList'] =
          this.blogCommentsList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BlogCommentsList {
  String? userId;
  String? comment;
  int? insertDate;
  String? blogCommentId;
  String? userName;
  String? userProfilePic;
  List<ReplyData>? replyData;
  String? eventCommentId;
  bool? showReplies;


  BlogCommentsList(
      {this.userId,
        this.comment,
        this.insertDate,
        this.blogCommentId,
        this.userName,
        this.userProfilePic,
        this.replyData,
        this.eventCommentId,this.showReplies});

  BlogCommentsList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    comment = json['comment'];
    insertDate = json['insertDate'];
    blogCommentId = json['blogCommentId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    if (json['replyData'] != null) {
      replyData = <ReplyData>[];
      json['replyData'].forEach((v) {
        replyData?.add(new ReplyData.fromJson(v));
      });
    }
    eventCommentId = json['eventCommentId'];
    showReplies=false;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['insertDate'] = this.insertDate;
    data['blogCommentId'] = this.blogCommentId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    if (this.replyData != null) {
      data['replyData'] = this.replyData?.map((v) => v.toJson()).toList();
    }
    data['eventCommentId'] = this.eventCommentId;
    return data;
  }
}

class ReplyData {
  String? comment;
  int? insertDate;
  String? replyCommentId;
  String? userId;
  String? userName;
  String? userProfilePic;

  ReplyData(
      {this.comment,
        this.insertDate,
        this.replyCommentId,
        this.userId,
        this.userName,
        this.userProfilePic});

  ReplyData.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    insertDate = json['insertDate'];
    replyCommentId = json['replyCommentId'];
    userId = json['userId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment'] = this.comment;
    data['insertDate'] = this.insertDate;
    data['replyCommentId'] = this.replyCommentId;
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    return data;
  }
}
