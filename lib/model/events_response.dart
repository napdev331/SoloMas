class EventResponse {
  int? statusCode;
  String? message;
  Data? data;

  EventResponse({this.statusCode, this.message, this.data});

  EventResponse.fromJson(Map<String, dynamic> json) {
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
  List<EventList>? eventList;

  Data({this.totalCount, this.eventList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['eventList'] != null) {
      eventList = <EventList>[];
      json['eventList'].forEach((v) {
        eventList?.add(new EventList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.eventList != null) {
      data['eventList'] = this.eventList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventList {
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
  int? reviewCount;
  String? locationName;
  Location? location;
  int? insertDate;
  List<EventLatestFiveMembers>? eventLatestFiveMembers;
  String? eventId;
  bool? isEventJoined;
  bool? isEventReportedByMe;
  String? userName;
  String? userProfilePic;
  String? carnivalTitle;
  int? totalLikes;
  bool? isLike;

  EventList({
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
    this.reviewCount,
    this.locationName,
    this.location,
    this.insertDate,
    this.eventLatestFiveMembers,
    this.eventId,
    this.isEventJoined,
    this.isEventReportedByMe,
    this.userName,
    this.userProfilePic,
    this.carnivalTitle,
    this.totalLikes,
    this.isLike,
  });

  EventList.fromJson(Map<String, dynamic> json) {
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
    reviewCount = json['reviewCount'];
    locationName = json['locationName'];
    totalLikes = json['totalLikes'];
    isLike = json['isLike'];

    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    insertDate = json['insertDate'];
    if (json['eventLatestFiveMembers'] != null) {
      eventLatestFiveMembers = <EventLatestFiveMembers>[];
      json['eventLatestFiveMembers'].forEach((v) {
        eventLatestFiveMembers?.add(new EventLatestFiveMembers.fromJson(v));
      });
    }
    eventId = json['eventId'];
    isEventJoined = json['isEventJoined'];
    isEventReportedByMe = json['isEventReportedByMe'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    carnivalTitle = json['carnivalTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['reviewCount'] = this.reviewCount;
    data['locationName'] = this.locationName;
    data['totalLikes'] = this.totalLikes;

    if (this.location != null) {
      data['location'] = this.location?.toJson();
    }
    data['insertDate'] = this.insertDate;
    if (this.eventLatestFiveMembers != null) {
      data['eventLatestFiveMembers'] =
          this.eventLatestFiveMembers?.map((v) => v.toJson()).toList();
    }
    data['eventId'] = this.eventId;
    data['isEventJoined'] = this.isEventJoined;
    data['isEventReportedByMe'] = this.isEventReportedByMe;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['carnivalTitle'] = this.carnivalTitle;
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

class EventLatestFiveMembers {
  String? userId;
  String? userName;
  String? userProfilePic;

  EventLatestFiveMembers({this.userId, this.userName, this.userProfilePic});

  EventLatestFiveMembers.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    return data;
  }
}
