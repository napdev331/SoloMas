class DeleteReviewEvent {
  int? statusCode;
  String? message;
  Data? data;

  DeleteReviewEvent({this.statusCode, this.message, this.data});

  DeleteReviewEvent.fromJson(Map<String, dynamic> json) {
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
  String? message;
  DeletedDoc? deletedDoc;

  Data({this.message, this.deletedDoc});

  Data.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    deletedDoc = json['deletedDoc'] != null
        ? new DeletedDoc.fromJson(json['deletedDoc'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.deletedDoc != null) {
      data['deletedDoc'] = this.deletedDoc?.toJson();
    }
    return data;
  }
}

class DeletedDoc {
  String? sId;
  String? eventId;
  String? eventCreatorId;
  String? userId;
  String? review;
  String? creationDate;
  int? insertDate;
  int? iV;

  DeletedDoc(
      {this.sId,
        this.eventId,
        this.eventCreatorId,
        this.userId,
        this.review,
        this.creationDate,
        this.insertDate,
        this.iV});

  DeletedDoc.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    eventId = json['eventId'];
    eventCreatorId = json['eventCreatorId'];
    userId = json['userId'];
    review = json['review'];
    creationDate = json['creationDate'];
    insertDate = json['insertDate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['eventId'] = this.eventId;
    data['eventCreatorId'] = this.eventCreatorId;
    data['userId'] = this.userId;
    data['review'] = this.review;
    data['creationDate'] = this.creationDate;
    data['insertDate'] = this.insertDate;
    data['__v'] = this.iV;
    return data;
  }
}
