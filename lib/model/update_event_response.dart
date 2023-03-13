class UpdateEventResponse {
  int? statusCode;
  String? message;
  Data? data;

  UpdateEventResponse({this.statusCode, this.message, this.data});

  UpdateEventResponse.fromJson(Map<String, dynamic> json) {
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
  Event? event;

  Data({this.event});

  Data.fromJson(Map<String, dynamic> json) {
    event = json['event'] != null ? new Event.fromJson(json['event']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.event != null) {
      data['event'] = this.event?.toJson();
    }
    return data;
  }
}

class Event {
  Location? location;
  String? userId;
  String? image;
  String? title;
  String? category;
  String? carnivalId;
  String? host;
  String? description;
  String? startDate;
  String? startTime;
  String? endDate;
  String? endTime;
  int? startEpoch;
  int? endEpoch;
  String? timezone;
  int? totalComments;
  int? totalMembers;
  bool? isReported;
  int? reportCount;
  String? locationName;
  String? sId;
  LocationPoint? locationPoint;
  int? insertDate;
  int? iV;
  String? eventId;

  Event(
      {this.location,
        this.userId,
        this.image,
        this.title,
        this.category,
        this.carnivalId,
        this.host,
        this.description,
        this.startDate,
        this.startTime,
        this.endDate,
        this.endTime,
        this.startEpoch,
        this.endEpoch,
        this.timezone,
        this.totalComments,
        this.totalMembers,
        this.isReported,
        this.reportCount,
        this.locationName,
        this.sId,
        this.locationPoint,
        this.insertDate,
        this.iV,
        this.eventId});

  Event.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    userId = json['userId'];
    image = json['image'];
    title = json['title'];
    category = json['category'];
    carnivalId = json['carnivalId'];
    host = json['host'];
    description = json['description'];
    startDate = json['startDate'];
    startTime = json['startTime'];
    endDate = json['endDate'];
    endTime = json['endTime'];
    startEpoch = json['startEpoch'];
    endEpoch = json['endEpoch'];
    timezone = json['timezone'];
    totalComments = json['totalComments'];
    totalMembers = json['totalMembers'];
    isReported = json['isReported'];
    reportCount = json['reportCount'];
    locationName = json['locationName'];
    sId = json['_id'];
    locationPoint = json['locationPoint'] != null
        ? new LocationPoint.fromJson(json['locationPoint'])
        : null;
    insertDate = json['insertDate'];
    iV = json['__v'];
    eventId = json['eventId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location?.toJson();
    }
    data['userId'] = this.userId;
    data['image'] = this.image;
    data['title'] = this.title;
    data['category'] = this.category;
    data['carnivalId'] = this.carnivalId;
    data['host'] = this.host;
    data['description'] = this.description;
    data['startDate'] = this.startDate;
    data['startTime'] = this.startTime;
    data['endDate'] = this.endDate;
    data['endTime'] = this.endTime;
    data['startEpoch'] = this.startEpoch;
    data['endEpoch'] = this.endEpoch;
    data['timezone'] = this.timezone;
    data['totalComments'] = this.totalComments;
    data['totalMembers'] = this.totalMembers;
    data['isReported'] = this.isReported;
    data['reportCount'] = this.reportCount;
    data['locationName'] = this.locationName;
    data['_id'] = this.sId;
    if (this.locationPoint != null) {
      data['locationPoint'] = this.locationPoint?.toJson();
    }
    data['insertDate'] = this.insertDate;
    data['__v'] = this.iV;
    data['eventId'] = this.eventId;
    return data;
  }
}

class Location {
  double? lat;
  double? lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}

class LocationPoint {
  String? type;
  List<double>? coordinates;

  LocationPoint({this.type, this.coordinates});

  LocationPoint.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}
