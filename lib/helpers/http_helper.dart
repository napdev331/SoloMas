import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:solomas/helpers/api_constants.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/resources_helper/strings.dart';

class HttpHelper {
  
  static final HttpHelper _getInstance = HttpHelper._internal();
  
  HttpHelper._internal();

  factory HttpHelper() {
   
    return _getInstance;
  }
  
  Future<Map?> get({String? url, String? authToken}) async {
    
    Constants.printValue('API URL: ' + url.toString());

    Constants.printValue('AUTH TOKEN: ' + authToken.toString());

    var apiHeaders;

    if (authToken!.isNotEmpty)

      apiHeaders = {
        "Content-type"  : "application/json",
        "Authorization" : authToken
      };

    else

      apiHeaders = {
        "Content-type": "application/json",
      };

    var responseData;

    try {

      final apiResponse = await http.get(Uri.parse(url.toString()), headers: apiHeaders);

      Map<String, String> headers = apiResponse.headers;

      Constants.printValue("HEADERS: " + headers.toString());
  
      headers.forEach((String key, String authToken) {

        if (key == "authorization") {

          PrefHelper.setAuthToken(authToken);
        }
      });

      responseData = _returnResponse(response: apiResponse, isUserData:
      
      url == ApiConstants.API_GET_USER_DATA ? true : false);
  
    } on SocketException {
  
      CommonHelper.alertOk(StringHelper.noInternetTitle,
          StringHelper.noInternetMsg);
  
      return null;
    }

    return responseData;
  }

  Future<Map?> post({String? url, String? body, String authToken = ''}) async {

    Constants.printValue('API URL: ' + url.toString());

    Constants.printValue('API BODY: ' + body.toString());

    var apiHeaders;

    if (authToken.isNotEmpty)

      apiHeaders = {
        "Content-type": "application/json",
        "Authorization": authToken
      };

    else

      apiHeaders = {
        "Content-type": "application/json",
      };

    Constants.printValue('Api Headers: ' + apiHeaders.toString());

    var responseData;

    try {

      final apiResponse = await http.post(
          Uri.parse(url.toString()), body: body, headers: apiHeaders);

      Map<String, String> headers = apiResponse.headers;

      Constants.printValue("HEADERS: " + headers.toString());

      headers.forEach((String key, String authToken) {
  
        if (key == "authorization") {

          PrefHelper.setAuthToken(authToken);
        }
      });

      Constants.printValue("STATUS CODE: " + apiResponse.statusCode.toString());
      
      Constants.printValue("MESSAGE: " + apiResponse.body.toString());

      responseData = _returnResponse(response: apiResponse);

    } on SocketException {

      CommonHelper.alertOk(StringHelper.noInternetTitle,
          StringHelper.noInternetMsg);

      return null;
    }

    return responseData;
  }
  
  Future<dynamic> put({String? url, String? authToken, String? body}) async {
  
    Constants.printValue('API URL: ' + url.toString());

    Constants.printValue('API BODY: ' + body.toString());

    var apiHeaders;
  
    if (authToken!.isNotEmpty)
    
      apiHeaders = {
        "Content-type": "application/json",
        "Authorization": authToken
      };
  
    else
    
      apiHeaders = {
        "Content-type": "application/json",
      };
  
    Constants.printValue('Api Headers: ' + apiHeaders.toString());
  
    var responseData;
  
    try {
    
      final apiResponse = await http.put(
          Uri.parse(url.toString()), body: body, headers: apiHeaders);
    
      Map<String, String> headers = apiResponse.headers;
    
      Constants.printValue("HEADERS: " + headers.toString());
    
      headers.forEach((String key, String authToken) {
      
        if (key == "authorization") {
        
          PrefHelper.setAuthToken(authToken);
        }
      });

      responseData = _returnResponse(response: apiResponse);

      print("STATUS  CODE : " + apiResponse.statusCode.toString());
      
      print("ERRORS:  " + apiResponse.body);
      
    } on SocketException {
    
      CommonHelper.alertOk(StringHelper.noInternetTitle,
          StringHelper.noInternetMsg);
    
      return null;
    }
  
    return responseData;
  }

  Future<dynamic> delete({String? url, String? authToken}) async {
  
    Constants.printValue('API URL: ' + url.toString());
  
    var apiHeaders;
  
    if (authToken!.isNotEmpty)
    
      apiHeaders = {
        "Content-type": "application/json",
        "Authorization": authToken
      };
  
    else
    
      apiHeaders = {
        "Content-type": "application/json",
      };
  
    Constants.printValue('Api Headers: ' + apiHeaders.toString());
  
    var responseData;
  
    try {
    
      final apiResponse = await http.delete(Uri.parse(url.toString()), headers: apiHeaders);
    
      Map<String, String> headers = apiResponse.headers;
    
      Constants.printValue("HEADERS: " + headers.toString());
    
      headers.forEach((String key, String authToken) {
      
        if (key == "authorization") {
        
          PrefHelper.setAuthToken(authToken);
        }
      });
    
      responseData = _returnResponse(response: apiResponse);
    
    } on SocketException {
    
      CommonHelper.alertOk(StringHelper.noInternetTitle,
          StringHelper.noInternetMsg);
    
      return null;
    }
  
    return responseData;
  }

  Future<dynamic> uploadImage(File imageFile) async {

    var dio = Dio();

    dio.options.baseUrl = ApiConstants.BASE_URL;

    dio.options.connectTimeout = 10000;

    dio.options.receiveTimeout = 10000;

    var uploadURL = "s3upload/profilePic-upload";

    Constants.printValue("API REQUEST: " + ApiConstants.BASE_URL + uploadURL);

    String fileName = imageFile.path.split('/').last;

    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName)
    });

    var apiResponse = await dio.post(uploadURL,
      data: formData,
      options: Options(
        method: 'POST',
        responseType: ResponseType.json // or ResponseType.JSON
      ));

    if (apiResponse.statusCode == 200) {

      return apiResponse.data;

    } else {

      CommonHelper.checkStatusCode(apiResponse.statusCode ?? 0, StringHelper.error,
        'Failed to upload image on server. Please try again.');

      return null;
    }
  }

  Future uploadMultipleImage(List multipartImageList ) async {
    List<MultipartFile> multipart = <MultipartFile>[];

    print("uploadMultiple $multipartImageList");

    for (File asset in multipartImageList) {
      var multipartFile = await MultipartFile.fromFile(
        asset.path,
        filename: asset.path.toString(),
      );
      multipart.add(multipartFile);
    }

    var formData = FormData.fromMap({
      "files": multipart,
    });

    var dio = Dio();

    dio.options.baseUrl = ApiConstants.BASE_URL;
    dio.options.connectTimeout = 30000;
    dio.options.receiveTimeout = 30000;

    var uploadUrl = ApiConstants.API_GET_MULTIPLE_IMAGES;

    try {
      var apiResponse = await dio.post(uploadUrl, data: formData, options: Options(
          method: 'POST',
          responseType: ResponseType.json // or ResponseType.JSON
      ));

      if (apiResponse.statusCode == 200) {
        print("STATUS CODE" + apiResponse.statusCode.toString());
        print("MESSAGE BODY" + apiResponse.toString());
        return apiResponse.data;
      } else {
        print("error");
        return null;
      }
    } catch (e) {
      print("exception : $e");
    }
  }

}



dynamic _returnResponse({http.Response? response, bool? isUserData}) {
  
  switch (response?.statusCode) {
    
    case 200:
  
      Map<String, dynamic> responseMap = json.decode(response!.body.toString());
  
      Constants.printValue('API RESPONSE: ' + responseMap.toString());

      return responseMap;
  
    case 401:
  
      Map<String, dynamic> responseMap = json.decode(response!.body.toString());
  
      Constants.printValue('API RESPONSE: ' + responseMap.toString());

      return responseMap;

      break;

    case 403:
  
      Map<String, dynamic> responseMap = json.decode(response!.body.toString());

      Constants.printValue('API RESPONSE: ' + responseMap.toString());

      return responseMap;
  
    case 400:
  
      Map<String, dynamic> responseMap = json.decode(response!.body.toString());
  
      Constants.printValue('API RESPONSE: ' + responseMap.toString());
  
      return responseMap;

    case 500:

      Map<String, dynamic> responseMap = json.decode(response!.body.toString());

      Constants.printValue('API RESPONSE: ' + responseMap.toString());

      return responseMap;

    case 503:
    
      CommonHelper.alertOk("Error", "Server Down");

      return null;
  
    default:
  
      return null;
  }
}