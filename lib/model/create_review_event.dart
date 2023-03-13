class CreatReviewEvent {
  int? statusCode;
  String? message;
  Data? data;

  CreatReviewEvent({this.statusCode, this.message, this.data});

  CreatReviewEvent.fromJson(Map<String, dynamic> json) {
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
  Review? review;
  String? message;

  Data({this.review,this.message});

  Data.fromJson(Map<String, dynamic> json) {
    review =
    json['review'] != null ? new Review.fromJson(json['review']) : null;
    message = json['message'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.review != null) {
      data['review'] = this.review?.toJson();
    }
    return data;
  }
}

class Review {
  String? eventId;
  String? eventCreatorId;
  String? userId;
  String? review;
  String? sId;
  String? creationDate;
  int? insertDate;
  int? iV;

  Review(
      {this.eventId,
        this.eventCreatorId,
        this.userId,
        this.review,
        this.sId,
        this.creationDate,
        this.insertDate,
        this.iV});

  Review.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventCreatorId = json['eventCreatorId'];
    userId = json['userId'];
    review = json['review'];
    sId = json['_id'];
    creationDate = json['creationDate'];
    insertDate = json['insertDate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['eventCreatorId'] = this.eventCreatorId;
    data['userId'] = this.userId;
    data['review'] = this.review;
    data['_id'] = this.sId;
    data['creationDate'] = this.creationDate;
    data['insertDate'] = this.insertDate;
    data['__v'] = this.iV;
    return data;
  }
}
