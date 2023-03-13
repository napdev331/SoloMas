class ServicesContinentModel {
  int? statusCode;
  String? message;
  Data? data;

  ServicesContinentModel({this.statusCode, this.message, this.data});

  ServicesContinentModel.fromJson(Map<String, dynamic> json) {
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
  List<ServiceList>? serviceList;

  Data({this.serviceList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['serviceList'] != null) {
      serviceList = <ServiceList>[];
      json['serviceList'].forEach((v) {
        serviceList?.add(new ServiceList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.serviceList != null) {
      data['serviceList'] = this.serviceList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceList {
  String? continent;
  String? image;
  String? creationDate;
  int? insertDate;
  int? carnivalCount;

  ServiceList(
      {this.continent,
      this.image,
      this.creationDate,
      this.insertDate,
      this.carnivalCount});

  ServiceList.fromJson(Map<String, dynamic> json) {
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
