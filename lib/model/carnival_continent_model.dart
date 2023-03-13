class ContinentsModel {
  int? statusCode;
  String? message;
  Data? data;

  ContinentsModel({this.statusCode, this.message, this.data});

  ContinentsModel.fromJson(Map<String, dynamic> json) {
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
  List<ContinentList>? continentList;

  Data({this.continentList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['continentList'] != null) {
      continentList =  <ContinentList>[];
      json['continentList'].forEach((v) {
        continentList?.add(new ContinentList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.continentList != null) {
      data['continentList'] =
          this.continentList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ContinentList {
  String? continent;
  String? creationDate;
  int? insertDate;
  String? image;
  int? carnivalCount;

  ContinentList(
      {this.continent,
        this.creationDate,
        this.insertDate,
        this.image,
        this.carnivalCount});

  ContinentList.fromJson(Map<String, dynamic> json) {
    continent = json['continent'];
    creationDate = json['creationDate'];
    insertDate = json['insertDate'];
    image = json['image'];
    carnivalCount = json['carnivalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['continent'] = this.continent;
    data['creationDate'] = this.creationDate;
    data['insertDate'] = this.insertDate;
    data['image'] = this.image;
    data['carnivalCount'] = this.carnivalCount;
    return data;
  }
}
