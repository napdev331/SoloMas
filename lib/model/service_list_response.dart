class ServiceListResponse {
  int? statusCode;
  String? message;
  Data? data;

  ServiceListResponse({this.statusCode, this.message, this.data});

  ServiceListResponse.fromJson(Map<String, dynamic> json) {
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
  List<ServiceList>? serviceList;

  Data({this.totalCount, this.serviceList});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['serviceList'] != null) {
      serviceList = <ServiceList>[];
      json['serviceList'].forEach((v) {
        serviceList?.add(new ServiceList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.serviceList != null) {
      data['serviceList'] = this.serviceList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceList {
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
  String? locationName;
  Location? location;
  int? insertDate;
  String? serviceId;
  bool? isServiceReportedByMe;
  bool? isLike;
  String? userName;
  String? userProfilePic;
  List<String>? carnivalTitle;

  ServiceList(
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
      this.locationName,
      this.location,
      this.insertDate,
      this.serviceId,
      this.isServiceReportedByMe,
      this.isLike,
      this.userName,
      this.userProfilePic,
      this.carnivalTitle});

  ServiceList.fromJson(Map<String, dynamic> json) {
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
    locationName = json['locationName'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
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
    data['locationName'] = this.locationName;
    if (this.location != null) {
      data['location'] = this.location?.toJson();
    }
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
