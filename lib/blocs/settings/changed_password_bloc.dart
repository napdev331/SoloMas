import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/model/change_password_model.dart';

import '../bloc.dart';

class ChangePasswordBloc extends Object with PasswordValidator implements Bloc {
  
  final _subject = PublishSubject<ChangedPasswordModel>();
  
  var _apiHelper = ApiHelper();
  
  final _oldController = BehaviorSubject<String>();
  
  final _newController = BehaviorSubject<String>();
  
  final _confirmController = BehaviorSubject<String>();
  
  Function(String) get oldChanged => _oldController.sink.add;
  
  Function(String) get newChanged => _newController.sink.add;
  
  Function(String) get confirmChanged => _confirmController.sink.add;
  
  Stream <String> get oldStream => _oldController.stream.transform(_oldValidator);

  Stream<String> get newPassword =>
      _newController.stream.transform(_passwordValidator).doOnData((String c) {
  
    if (_oldController.value == c) {
  
      _newController.addError('Old password and New Password must not be same.');
    }
  });

  Stream<String> get confirmPassword => _confirmController.stream.transform(_passwordValidator).doOnData((String c) {
      
        if (0 != _newController.value?.compareTo(c)) {
        
          _confirmController.addError('Confirm Password and Password are not match each other.');
        }
      });

  Stream<bool> get saveCheck =>
      Rx.combineLatest3(oldStream, newPassword, confirmPassword,
              (oldPassword, newPassword, confirmPassword) => true);

  Stream<ChangedPasswordModel> get submitComplaint => _subject.stream;
  
  Future<dynamic> changedPassword(CommonHelper commonHelper, String body,
      String authToken) async {

    try {

      ChangedPasswordModel changedModel = await _apiHelper.changedPassword(body, authToken);

      if(changedModel.statusCode == 200) {

        commonHelper.showAlertIntent('Success', "Your password has been changed successfully");

        _subject.sink.add(changedModel);
        
      } else {

        _subject.sink.addError(changedModel.data.toString());
      }
      
    } catch (error) {
  
      _subject.sink.addError("Something Error");
    }
  }
  
  @override
  void dispose() {
    
    _subject.close();
    
    _oldController.close();
    
    _newController.close();

    _confirmController.close();
  }
}

mixin PasswordValidator {
  
  var _oldValidator = StreamTransformer<String, String>.fromHandlers(
    
      handleData: (oldPassword, sink) {
      
        if (oldPassword.toString().length >= 6) {
        
          sink.add(oldPassword);
        
        } else {
        
          sink.addError('The password must be at least 6 character long.');
        }
      }
  );

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