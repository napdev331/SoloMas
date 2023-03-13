class CreateServiceResponse {
  int? statusCode;
  String? message;
  Data? data;

  CreateServiceResponse({this.statusCode, this.message, this.data});

  CreateServiceResponse.fromJson(Map<String, dynamic> json) {
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
  Service? service;

  Data({this.service});

  Data.fromJson(Map<String, dynamic> json) {
    service =
    json['service'] != null ? new Service.fromJson(json['service']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.service != null) {
      data['service'] = this.service?.toJson();
    }
    return data;
  }
}

class Service {
  String? userId;
  String? continent;
  String? image;
  String? businessName;
  String? phoneNumber;
  String? category;
  List<String>? carnivalId;
  String? email;
  String? website;
  bool? isReported;
  int? reportCount;
  int? totalComments;
  int? totalLikes;
  String? locationName;
  String? sId;
  Location? location;
  String? creationDate;
  int? insertDate;
  LocationPoint? locationPoint;
  int? iV;
  String? serviceId;

  Service(
      {this.userId,
        this.continent,
        this.image,
        this.businessName,
        this.phoneNumber,
        this.category,
        this.carnivalId,
        this.email,
        this.website,
        this.isReported,
        this.reportCount,
        this.totalComments,
        this.totalLikes,
        this.locationName,
        this.sId,
        this.location,
        this.creationDate,
        this.insertDate,
        this.locationPoint,
        this.iV,
        this.serviceId});

  Service.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    continent = json['continent'];
    image = json['image'];
    businessName = json['businessName'];
    phoneNumber = json['phoneNumber'];
    category = json['category'];
    carnivalId = json['carnivalId'].cast<String>();
    email = json['email'];
    website = json['website'];
    isReported = json['isReported'];
    reportCount = json['reportCount'];
    totalComments = json['totalComments'];
    totalLikes = json['totalLikes'];
    locationName = json['locationName'];
    sId = json['_id'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    creationDate = json['creationDate'];
    insertDate = json['insertDate'];
    locationPoint = json['locationPoint'] != null
        ? new LocationPoint.fromJson(json['locationPoint'])
        : null;
    iV = json['__v'];
    serviceId = json['serviceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['continent'] = this.continent;
    data['image'] = this.image;
    data['businessName'] = this.businessName;
    data['phoneNumber'] = this.phoneNumber;
    data['category'] = this.category;
    data['carnivalId'] = this.carnivalId;
    data['email'] = this.email;
    data['website'] = this.website;
    data['isReported'] = this.isReported;
    data['reportCount'] = this.reportCount;
    data['totalComments'] = this.totalComments;
    data['totalLikes'] = this.totalLikes;
    data['locationName'] = this.locationName;
    data['_id'] = this.sId;
    if (this.location != null) {
      data['location'] = this.location?.toJson();
    }
    data['creationDate'] = this.creationDate;
    data['insertDate'] = this.insertDate;
    if (this.locationPoint != null) {
      data['locationPoint'] = this.locationPoint?.toJson();
    }
    data['__v'] = this.iV;
    data['serviceId'] = this.serviceId;
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
  List<double>? coordinates;
  String? sId;
  String? type;

  LocationPoint({this.coordinates, this.sId, this.type});

  LocationPoint.fromJson(Map<String, dynamic> json) {
    coordinates = json['coordinates'].cast<double>();
    sId = json['_id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coordinates'] = this.coordinates;
    data['_id'] = this.sId;
    data['type'] = this.type;
    return data;
  }
}
