class EventCategory {
  int? statusCode;
  String? message;
  Data? data;

  EventCategory({this.statusCode, this.message, this.data});

  EventCategory.fromJson(Map<String, dynamic> json) {
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
  List<EventCategoryList>? eventCategoryList;

  Data({this.eventCategoryList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['eventCategoryList'] != null) {
      eventCategoryList = <EventCategoryList>[];
      json['eventCategoryList'].forEach((v) {
        eventCategoryList?.add(new EventCategoryList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eventCategoryList != null) {
      data['eventCategoryList'] =
          this.eventCategoryList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventCategoryList {
  String? eventCategoryId;

  EventCategoryList({this.eventCategoryId});

  EventCategoryList.fromJson(Map<String, dynamic> json) {
    eventCategoryId = json['eventCategoryId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventCategoryId'] = this.eventCategoryId;
    return data;
  }
}
