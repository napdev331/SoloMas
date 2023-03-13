class CarnivalTilesResponse {
  int? statusCode;
  String? message;
  Data? data;

  CarnivalTilesResponse({this.statusCode, this.message, this.data});

  CarnivalTilesResponse.fromJson(Map<String, dynamic> json) {
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
  List<CarnivalList>? carnivalList;

  Data({this.carnivalList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['carnivalList'] != null) {
      carnivalList = <CarnivalList>[];
      json['carnivalList'].forEach((v) {
        carnivalList?.add(new CarnivalList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.carnivalList != null) {
      data['carnivalList'] = this.carnivalList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CarnivalList {
  String? title;
  String? carnivalId;

  CarnivalList({this.title, this.carnivalId});

  CarnivalList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    carnivalId = json['carnivalId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['carnivalId'] = this.carnivalId;
    return data;
  }
}
