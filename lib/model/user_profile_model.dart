import 'package:solomas/helpers/common_helper.dart';

class UserProfileModel {
  int? statusCode;

  String? message;

  Data? data;

  UserProfileModel({this.statusCode, this.message, this.data});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(
          statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  Response? response;

  List<UpcomingCarnival>? upcomingCarnival;

  List<Photo>? photo;

  List<GroupList>? groupList;

  List<ContestWon>? contestWon;

  List<MyEventList>? myEventList;
  List<MyEventListProfile>? myEventListProfile;

  List<UpcomingJoinedEventList>? upcomingJoinedEventList;

  List<MyServiceList>? myServiceList;

  Data(
      {this.response,
      this.upcomingCarnival,
      this.photo,
      this.groupList,
      this.contestWon,
      this.myEventList,
      this.upcomingJoinedEventList,
      this.myServiceList});

  Data.fromJson(Map<String, dynamic> json) {
    response =
        json['response'] != null ? Response.fromJson(json['response']) : null;

    if (json['upcomingCarnival'] != null) {
      upcomingCarnival = <UpcomingCarnival>[];

      json['upcomingCarnival'].forEach((v) {
        upcomingCarnival?.add(UpcomingCarnival.fromJson(v));
      });
    }

    if (json['photo'] != null) {
      photo = <Photo>[];

      json['photo'].forEach((v) {
        photo?.add(Photo.fromJson(v));
      });
    }

    if (json['groupList'] != null) {
      groupList = <GroupList>[];

      json['groupList'].forEach((v) {
        groupList?.add(GroupList.fromJson(v));
      });
    }

    if (json['contestWon'] != null) {
      contestWon = <ContestWon>[];

      json['contestWon'].forEach((v) {
        contestWon?.add(new ContestWon.fromJson(v));
      });
    }

    if (json['myEventList'] != null) {
      myEventList = <MyEventList>[];
      myEventListProfile = <MyEventListProfile>[];
      json['myEventList'].forEach((v) {
        myEventListProfile?.add(MyEventListProfile.fromJson(v));
        myEventList?.add(new MyEventList.fromJson(v));
      });
    }
    if (json['upcomingJoinedEventList'] != null) {
      upcomingJoinedEventList = <UpcomingJoinedEventList>[];
      json['upcomingJoinedEventList'].forEach((v) {
        myEventListProfile?.add(MyEventListProfile.fromJson(v));
        upcomingJoinedEventList?.add(new UpcomingJoinedEventList.fromJson(v));
      });
    }
    if (json['myServiceList'] != null) {
      myServiceList = <MyServiceList>[];
      json['myServiceList'].forEach((v) {
        myServiceList?.add(new MyServiceList.fromJson(v));
      });
    }
  }
}

class Response {
  Location? location;

  String? fullName,
      mobile,
      email,
      profilePic,
      userType,
      gender,
      status,
      locationName,
      coverImage,
      band,
      userId,
      statusTitle;

  int? age, insertDate, reportCount, totalStatusPoint;

  bool? isReported;

  Response(
      {this.location,
      this.fullName,
      this.mobile,
      this.email,
      this.profilePic,
      this.userType,
      this.age,
      this.gender,
      this.insertDate,
      this.status,
      this.locationName,
      this.coverImage,
      this.isReported,
      this.reportCount,
      this.band,
      this.userId,
      this.totalStatusPoint,
      this.statusTitle});

  Response.fromJson(Map<String, dynamic> json) {
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;

    fullName = json['fullName'];

    mobile = json['mobile'] ?? "";

    email = json['email'];

    profilePic = json['profilePic'];

    userType = json['userType'];

    age = json['age'];

    gender = json['gender'] ?? "";

    insertDate = json['insertDate'];

    status = json['status'];

    locationName = json['locationName'];

    coverImage = json['coverImage'];

    isReported = json['isReported'];

    reportCount = json['reportCount'];

    band = json['band'];

    userId = json['userId'];

    totalStatusPoint = json['totalStatusPoint'];

    statusTitle = json['statusTitle'] ?? "";
  }
}

class Location {
  double? lat, lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];

    lng = json['lng'];
  }
}

class UpcomingCarnival {
  List<CarnivalData>? carnivalData;

  UpcomingCarnival({this.carnivalData});

  UpcomingCarnival.fromJson(Map<String, dynamic> json) {
    if (json['carnivalData'] != null) {
      carnivalData = <CarnivalData>[];

      json['carnivalData'].forEach((v) {
        carnivalData?.add(CarnivalData.fromJson(v));
      });
    }
  }
}

class CarnivalData {
  String? sId,
      locationName,
      title,
      description,
      coverImageUrl,
      creationDate,
      userBand;

  Location? location;

  List<String>? images;

  int? totalMembers, startDate, endDate, insertDate, iV;

  List<Bands>? bands;

  LocationPoint? locationPoint;

  CarnivalData(
      {this.sId,
      this.location,
      this.images,
      this.totalMembers,
      this.locationName,
      this.title,
      this.description,
      this.coverImageUrl,
      this.bands,
      this.startDate,
      this.endDate,
      this.creationDate,
      this.insertDate,
      this.locationPoint,
      this.iV,
      this.userBand});

  CarnivalData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;

    images = json['images'].cast<String>();

    totalMembers = json['totalMembers'];

    locationName = json['locationName'];

    title = json['title'];

    description = json['description'];

    coverImageUrl = json['coverImageUrl'];

    if (json['bands'] != null) {
      bands = <Bands>[];

      json['bands'].forEach((v) {
        bands?.add(Bands.fromJson(v));
      });
    }

    startDate = json['startDate'];

    endDate = json['endDate'];

    creationDate = json['creationDate'];

    insertDate = json['insertDate'];

    locationPoint = json['locationPoint'] != null
        ? LocationPoint.fromJson(json['locationPoint'])
        : null;

    iV = json['__v'];

    userBand = json['userBand'];
  }
}

class Bands {
  String? sId, name;

  Bands({this.sId, this.name});

  Bands.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    name = json['name'];
  }
}

class LocationPoint {
  List<double>? coordinates;

  String? sId, type;

  LocationPoint({this.coordinates, this.sId, this.type});

  LocationPoint.fromJson(Map<String, dynamic> json) {
    coordinates = json['coordinates'].cast<double>();

    sId = json['_id'];

    type = json['type'];
  }
}

class Photo {
  int? totalLikes, totalComments, insertDate;

  String? userId,
      publicFeedId,
      userName,
      userProfilePic,
      type,
      title,
      description;
  List<String>? image;

  bool? isLike;
  int? sliderPosition;

  Photo(
      {this.totalLikes,
      this.totalComments,
      this.userId,
      this.image,
      this.insertDate,
      this.publicFeedId,
      this.userName,
      this.userProfilePic,
      this.isLike,
      this.type,
      this.title,
      this.description,
      this.sliderPosition});

  Photo.fromJson(Map<String, dynamic> json) {
    totalLikes = json['totalLikes'];

    totalComments = json['totalComments'];

    userId = json['userId'];

    image = json['image'].cast<String>();

    insertDate = json['insertDate'];

    publicFeedId = json['publicFeedId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'];

    type = json['type'] ?? "image";

    title = json['title'] ?? "";

    description = json['description'] ?? "";

    isLike = json['isLike'];

    sliderPosition = 0;
  }
}

class GroupList {
  String? groupId, title, groupProfilePic, locationName;

  int? totalSubscribers;

  Location? location;

  GroupList(
      {this.groupId,
      this.title,
      this.groupProfilePic,
      this.totalSubscribers,
      this.location,
      this.locationName});

  GroupList.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];

    title = json['title'];

    groupProfilePic = json['groupProfilePic'];

    totalSubscribers = json['totalSubscribers'];

    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;

    locationName = json['locationName'];
  }
}

class ContestWon {
  String? contestName;

  ContestWon({this.contestName});

  ContestWon.fromJson(Map<String, dynamic> json) {
    contestName = json['contestName'];
  }
}

class MyEventList {
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
  String? locationName;
  Location? location;
  int? insertDate;
  String? eventId;
  bool? isEventJoined;
  bool? isEventReportedByMe;
  Null userName;
  Null userProfilePic;
  String? carnivalTitle;

  MyEventList(
      {this.userId,
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
      this.locationName,
      this.location,
      this.insertDate,
      this.eventId,
      this.isEventJoined,
      this.isEventReportedByMe,
      this.userName,
      this.userProfilePic,
      this.carnivalTitle});

  MyEventList.fromJson(Map<String, dynamic> json) {
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
    locationName = json['locationName'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    insertDate = json['insertDate'];
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
    data['locationName'] = this.locationName;
    if (this.location != null) {
      data['location'] = this.location;
    }
    data['insertDate'] = this.insertDate;
    data['eventId'] = this.eventId;
    data['isEventJoined'] = this.isEventJoined;
    data['isEventReportedByMe'] = this.isEventReportedByMe;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['carnivalTitle'] = this.carnivalTitle;
    return data;
  }
}

class MyEventListProfile {
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
  String? locationName;
  Location? location;
  int? insertDate;
  String? eventId;
  bool? isEventJoined;
  bool? isEventReportedByMe;
  Null userName;
  Null userProfilePic;
  String? carnivalTitle;

  MyEventListProfile(
      {this.userId,
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
      this.locationName,
      this.location,
      this.insertDate,
      this.eventId,
      this.isEventJoined,
      this.isEventReportedByMe,
      this.userName,
      this.userProfilePic,
      this.carnivalTitle});

  MyEventListProfile.fromJson(Map<String, dynamic> json) {
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
    locationName = json['locationName'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    insertDate = json['insertDate'];
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
    data['locationName'] = this.locationName;
    if (this.location != null) {
      data['location'] = this.location;
    }
    data['insertDate'] = this.insertDate;
    data['eventId'] = this.eventId;
    data['isEventJoined'] = this.isEventJoined;
    data['isEventReportedByMe'] = this.isEventReportedByMe;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['carnivalTitle'] = this.carnivalTitle;
    return data;
  }
}

class UpcomingJoinedEventList {
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
  String? locationName;
  Location? location;
  int? insertDate;
  String? eventId;
  bool? isEventJoined;
  bool? isEventReportedByMe;
  Null userName;
  Null userProfilePic;
  String? carnivalTitle;

  UpcomingJoinedEventList(
      {this.userId,
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
      this.locationName,
      this.location,
      this.insertDate,
      this.eventId,
      this.isEventJoined,
      this.isEventReportedByMe,
      this.userName,
      this.userProfilePic,
      this.carnivalTitle});

  UpcomingJoinedEventList.fromJson(Map<String, dynamic> json) {
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
    locationName = json['locationName'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    insertDate = json['insertDate'];
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
    data['locationName'] = this.locationName;
    if (this.location != null) {
      data['location'] = this.location;
    }
    data['insertDate'] = this.insertDate;
    data['eventId'] = this.eventId;
    data['isEventJoined'] = this.isEventJoined;
    data['isEventReportedByMe'] = this.isEventReportedByMe;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['carnivalTitle'] = this.carnivalTitle;
    return data;
  }
}

class MyServiceList {
  String? userId;
  String? image;
  String? businessName;
  String? phoneNumber;
  String? category;
  List<String>? carnivalId;
  String? email;
  String? website;
  int? totalComments;
  int? totalLikes;
  int? insertDate;
  String? serviceId;
  bool? isServiceReportedByMe;
  bool? isLike;
  Null userName;
  Null userProfilePic;
  List<String>? carnivalTitle;

  MyServiceList(
      {this.userId,
      this.image,
      this.businessName,
      this.phoneNumber,
      this.category,
      this.carnivalId,
      this.email,
      this.website,
      this.totalComments,
      this.totalLikes,
      this.insertDate,
      this.serviceId,
      this.isServiceReportedByMe,
      this.isLike,
      this.userName,
      this.userProfilePic,
      this.carnivalTitle});

  MyServiceList.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    image = json['image'];
    businessName = json['businessName'];
    phoneNumber = json['phoneNumber'];
    category = json['category'];
    carnivalId = json['carnivalId'].cast<String>();
    email = json['email'];
    website = json['website'];
    totalComments = json['totalComments'];
    totalLikes = json['totalLikes'];
    insertDate = json['insertDate'];
    serviceId = json['serviceId'];
    isServiceReportedByMe = json['isServiceReportedByMe'];
    isLike = json['isLike'];
    userName = json['userName'];
    userProfilePic = json['userProfilePic'];
    carnivalTitle = json['carnivalTitle'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['image'] = this.image;
    data['businessName'] = this.businessName;
    data['phoneNumber'] = this.phoneNumber;
    data['category'] = this.category;
    data['carnivalId'] = this.carnivalId;
    data['email'] = this.email;
    data['website'] = this.website;
    data['totalComments'] = this.totalComments;
    data['totalLikes'] = this.totalLikes;
    data['insertDate'] = this.insertDate;
    data['serviceId'] = this.serviceId;
    data['isServiceReportedByMe'] = this.isServiceReportedByMe;
    data['isLike'] = this.isLike;
    data['userName'] = this.userName;
    data['userProfilePic'] = this.userProfilePic;
    data['carnivalTitle'] = this.carnivalTitle;
    return data;
  }
}
