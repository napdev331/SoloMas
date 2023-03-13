import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/sign_up_model.dart';
import 'package:solomas/model/update_mobile_model.dart';
import 'package:solomas/model/verify_user_model.dart';

import '../bloc.dart';

class SignUpBloc extends Object with SignUpValidator implements Bloc {
  
  var _apiHelper = ApiHelper();

  BehaviorSubject<CreateOtpModel> _createOtpSubject = BehaviorSubject<CreateOtpModel>();

  BehaviorSubject<SignUpModel> _signUpSubject = BehaviorSubject<SignUpModel>();

  BehaviorSubject<VerifyUserModel> _userVerifySubject = BehaviorSubject<VerifyUserModel>();

  final _nameController = BehaviorSubject<String>();

  final _emailController = BehaviorSubject<String>();

  final _passwordController = BehaviorSubject<String>();

  Function(String) get nameChanged => _nameController.sink.add;
  
  Function(String) get emailChanged => _emailController.sink.add;

  Function(String) get passwordChanged => _passwordController.sink.add;

  Stream <String> get nameStream =>
      _nameController.stream.transform(_nameValidator);

  Stream <String> get emailStream =>
      _emailController.stream.transform(_emailValidator);

  Stream <String> get passwordStream =>
      _passwordController.stream.transform(_passwordValidator);

  Stream<bool> get signInCheck =>
      Rx.combineLatest3(
          nameStream, emailStream, passwordStream, (name, email, password) => true);

  bool agree = false;
  BehaviorSubject<bool> termsConditions = BehaviorSubject<bool>();
  StreamSink get termsConditionsSink => termsConditions.sink;
  Stream get termsConditionsStream => termsConditions.stream;

  void changeValue()
  {
    agree =! agree;
    print("agree is $agree");
    termsConditionsSink.add(agree);
  }


  Future<dynamic> createOtp(String body) async {

    try {

      CreateOtpModel response = await _apiHelper.createOtp(body);

      if(response.statusCode == 200) {

        _createOtpSubject.sink.add(response);

      } else {
      
        return Future.error(response.data.toString());
      }
    
    } catch (error) {
  
       return Future.error("Something Error");
    }
  }

  Future<dynamic> verifyUser(String body) async {
  
    try {
  
      VerifyUserModel response = await _apiHelper.verifyUser(body);
    
      if(response.statusCode == 200) {

        _userVerifySubject.sink.add(response);
    
      } else {
  
        CommonHelper.alertOk(response.message, response.data);
        
        return Future.error(response.data.toString());
      }
    
    } catch (error) {
    
      return Future.error("Something Error");
    }
  }

  Future<dynamic> signUpUser(String body) async {

    try {

      SignUpModel response = await _apiHelper.signUp(body);

      if(response.statusCode == 200) {

        _signUpSubject.sink.add(response);

        PrefHelper.setUserId(response.data!.userId.toString());

        PrefHelper.setUserName(response.data!.fullName.toString());

        PrefHelper.setUserAge(response.data!.age.toString());

        PrefHelper.setReferralCode(response.data!.referralCode.toString());

        var body = json.encode({
          "name" : response.data?.address?.name,
          "street": response.data?.address?.street,
          "email": response.data?.address?.email,
          "state": response.data?.address?.state,
          "city": response.data?.address?.city,
          "phoneNumber": response.data?.address?.phoneNumber
        });

        PrefHelper.setUserAddress(body);

        PrefHelper.setUserLocationAddress(response.data!.locationName.toString());

        PrefHelper.setUserProfilePic(response.data!.profilePic.toString());
  
        if(response.data?.userType == "app") PrefHelper.setUserType(true);
  
        else PrefHelper.setUserType(false);

      } else {
      
        return Future.error(response.data.toString());
      }

    } catch (error) {
    
      Future.error("Something Error");
    }
  }

  @override
  void dispose() {
    
    _nameController.close();

    _emailController.close();
    
    _passwordController.close();

    _createOtpSubject.close();

    _signUpSubject.close();

    _userVerifySubject.close();

    termsConditions.close();
  }
}

mixin SignUpValidator {
  
  var _nameValidator = StreamTransformer<String, String>.fromHandlers(
      
      handleData: (name, sink) {
        
        if (name.toString().length >= 2) {
        
          sink.add(name);
        
        } else if(name.toString().length < 2) {
          
          sink.addError('Full name must be at least two character long');

        } else {

          sink.addError('Please enter a valid name');
        }
      }
  );
  
  var _emailValidator = StreamTransformer<String, String>.fromHandlers(
      
      handleData: (email, sink) {
       
        if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email)) {
       
          sink.add(email);
       
        } else {
       
          sink.addError('Please enter a valid email.');
        }
      }
  );

  var _passwordValidator = StreamTransformer<String, String>.fromHandlers(

      handleData: (password, sink) {
        
        if (password.toString().length >= 6) {

          sink.add(password);

        } else {

          sink.addError('The password must be at least 6 character long');
        }
      }
  );




}