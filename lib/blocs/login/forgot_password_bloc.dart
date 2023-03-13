import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/update_mobile_model.dart';

import '../bloc.dart';

class ForgotPasswordBloc extends Object with ForgotPasswordValidators implements Bloc {

  final _emailController = BehaviorSubject<String>();

  var _apiHelper = ApiHelper();

  BehaviorSubject<CreateOtpModel> _createOtpSubject = BehaviorSubject<CreateOtpModel>();

  Function(String) get emailChanged => _emailController.sink.add;

  Stream <String> get emailStream =>
      _emailController.stream.transform(_emailValidator);

  Stream<String> get sendCheck => ValueConnectableStream(emailStream);

  Future<CreateOtpModel?> createOtp(String body) async {
  
    try {
    
      CreateOtpModel response = await _apiHelper.createOtp(body);
    
      if(response.statusCode == 200) {
      
        _createOtpSubject.sink.add(response);

        return response;
      
      } else {
      
        return response;
      }
    
    } catch (error) {
    
      Future.error("Something Error");
    }
    return null;
  }

  @override
  void dispose() {
  
    _emailController.close();

    _createOtpSubject.close();
  }
}

mixin ForgotPasswordValidators {

  var _emailValidator = StreamTransformer<String, String>.fromHandlers(

      handleData: (email, sink) {

        if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email)) {

          sink.add(email);

        } else {

          sink.addError('Please enter a valid email.');
        }
      }
  );
}