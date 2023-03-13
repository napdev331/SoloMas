import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/logout_model.dart';

import '../bloc.dart';

class LogoutBloc extends Object implements Bloc {
  
  BehaviorSubject<LogoutModel> _subject = BehaviorSubject<LogoutModel>();

  var _apiHelper = ApiHelper();
  
  BehaviorSubject<LogoutModel> get subject => _subject;

  Future<dynamic> userLogout(String body, String authToken) async {

    try {

      LogoutModel response = await _apiHelper.userLogout(body, authToken);

      if(response.statusCode == 200) {

        _subject.sink.add(response);

      } else {

        return Future.error(response.data.toString());
      }
      
    } catch (error) {

      return Future.error("Something Error");
    }
  }
  
  @override
  void dispose() {
    
    _subject.close();
  }
}