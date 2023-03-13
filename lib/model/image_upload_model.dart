class ImageUploadModel {
  String? apiId;
  int? statusCode;
  String? message;
  Data? data;

  ImageUploadModel({this.apiId, this.statusCode, this.message, this.data});

  ImageUploadModel.fromJson(Map<String, dynamic> json) {
    apiId = json['apiId'];
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['apiId'] = apiId;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  List<Url>? url;

  Data({this.url});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['url'] != null) {
      url = <Url>[];
      json['url'].forEach((v) {
        url?.add(Url.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (url != null) {
      data['url'] = url?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Url {
  String? url;

  Url({this.url});

  Url.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}
