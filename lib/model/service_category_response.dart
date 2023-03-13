class ServiceCategoryResponse {
  int? statusCode;
  String? message;
  Data? data;

  ServiceCategoryResponse({this.statusCode, this.message, this.data});

  ServiceCategoryResponse.fromJson(Map<String, dynamic> json) {
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
  List<ServiceCategoryList>? serviceCategoryList;

  Data({this.serviceCategoryList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['serviceCategoryList'] != null) {
      serviceCategoryList = <ServiceCategoryList>[];
      json['serviceCategoryList'].forEach((v) {
        serviceCategoryList?.add(new ServiceCategoryList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.serviceCategoryList != null) {
      data['serviceCategoryList'] =
          this.serviceCategoryList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceCategoryList {
  String? serviceCategoryId;

  ServiceCategoryList({this.serviceCategoryId});

  ServiceCategoryList.fromJson(Map<String, dynamic> json) {
    serviceCategoryId = json['serviceCategoryId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceCategoryId'] = this.serviceCategoryId;
    return data;
  }
}
