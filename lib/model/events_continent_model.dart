class EventsContinentModel {
  int? statusCode;
  String? message;
  Data? data;

  EventsContinentModel({this.statusCode, this.message, this.data});

  EventsContinentModel.fromJson(Map<String, dynamic> json) {
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
  List<EventList>? eventList;

  Data({this.eventList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['eventList'] != null) {
      eventList = <EventList>[];
      json['eventList'].forEach((v) {
        eventList?.add(new EventList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eventList != null) {
      data['eventList'] = this.eventList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventList {
  String? continent;
  String? image;
  String? creationDate;
  int? insertDate;
  int? carnivalCount;

  EventList(
      {this.continent,
      this.image,
      this.creationDate,
      this.insertDate,
      this.carnivalCount});

  EventList.fromJson(Map<String, dynamic> json) {
    continent = json['continent'];
    image = json['image'];
    creationDate = json['creationDate'];
    insertDate = json['insertDate'];
    carnivalCount = json['carnivalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['continent'] = this.continent;
    data['image'] = this.image;
    data['creationDate'] = this.creationDate;
    data['insertDate'] = this.insertDate;
    data['carnivalCount'] = this.carnivalCount;
    return data;
  }
}
