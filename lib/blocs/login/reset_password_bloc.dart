import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/reset_password_model.dart';

import '../bloc.dart';

class ResetPasswordBloc extends Object with ResetPasswordValidator implements Bloc {

  var _apiHelper = ApiHelper();

  BehaviorSubject<ResetPasswordModel> _resetOtpSubject = BehaviorSubject<ResetPasswordModel>();

   final _newPasswordController = BehaviorSubject<String>();
  
   final _confirmController = BehaviorSubject<String>();
  
  Function(String) get newPasswordChanged => _newPasswordController.sink.add;
  
  Function(String) get confirmChanged => _confirmController.sink.add;
  
  Stream <String> get newPasswordStream =>
      _newPasswordController.stream.transform(_passwordValidator);
  
  Stream<String> get confirmPassword =>
      _confirmController.stream.transform(_passwordValidator).doOnData((String c) {

        if (0 != _newPasswordController.value?.compareTo(c)) {
  
          _confirmController.addError('Confirm Password and Password are not match each other.');
        }
      });
  
  Stream<bool> get passwordCheck => Rx.combineLatest2(
      newPasswordStream, confirmPassword, (newPassword, confirmPassword) => true);

  Future<dynamic> resetPassword(String body) async {
  
    try {
    
      ResetPasswordModel response = await _apiHelper.resetPassword(body);
    
      if(response.statusCode == 200) {
  
        _resetOtpSubject.sink.add(response);
      
      } else {
      
        return Future.error(response.data.toString());
      }
    
    } catch (error) {
    
     return Future.error("Something Error");
    }
  }
  
  @override
  void dispose() {
  
    _newPasswordController.close();

    _confirmController.close();

    _resetOtpSubject.close();
  }
}

mixin ResetPasswordValidator {
  
  var _passwordValidator = StreamTransformer<String, String>.fromHandlers(
      
      handleData: (password, sink) {
        
        if (password.toString().length >= 6) {

          sink.add(password);

        } else {
          
          sink.addError('The password must be at least 6 character long.');
        }
      }
  );
}