import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/activities/home_activity.dart';
import 'package:solomas/activities/registration/add_location_activity.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/login_model.dart';
import 'package:solomas/model/social_login_model.dart';
import 'package:solomas/model/update_mobile_model.dart';

import '../bloc.dart';

class LoginBloc extends Object with LoginValidators implements Bloc {
  
  BehaviorSubject<CreateOtpModel> _createOtpSubject = BehaviorSubject<CreateOtpModel>();

  BehaviorSubject<LoginModel> _subject = BehaviorSubject<LoginModel>();

  BehaviorSubject<SocialLoginModel> _socialSubject = BehaviorSubject<SocialLoginModel>();

  final _emailController = BehaviorSubject<String>();

  final _passwordController = BehaviorSubject<String>();

  var _apiHelper = ApiHelper();

  Function(String) get emailChanged => _emailController.sink.add;

  Function(String) get passwordChanged => _passwordController.sink.add;

  Stream <String> get emailStream =>
      _emailController.stream.transform(_emailValidator);

  Stream <String> get passwordStream =>
      _passwordController.stream.transform(_passwordValidator);

  Stream<bool> get signInCheck =>
      Rx.combineLatest2(
          emailStream, passwordStream, (email, password) => true);

  BehaviorSubject<LoginModel> get subject => _subject;

  BehaviorSubject<SocialLoginModel> get socialSubject => _socialSubject;

  Future<dynamic> loginWithEmail(String body) async {

    try {

      LoginModel response = await _apiHelper.login(body);

      if(response.statusCode == 200) {
        
        _subject.sink.add(response);

        PrefHelper.setUserId(response.data!.userId.toString());

        PrefHelper.setUserName(response.data!.fullName.toString());

        PrefHelper.setUserStatus(response.data!.status.toString());

        PrefHelper.setUserAge(response.data!.age.toString());

        PrefHelper.setReferralCode(response.data!.referralCode.toString());

        PrefHelper.setUserAddress(encodeAddressData(response.data?.address as Address));

        PrefHelper.setUserLocationAddress(response.data!.locationName.toString());

        PrefHelper.setUserProfilePic(response.data!.profilePic.toString());

        if(response.data?.userType == "app") PrefHelper.setUserType(true);

        else PrefHelper.setUserType(false);
  
      } else {

        return Future.error(response.data.toString());
      }

    } catch (error) {

      return Future.error("Something Error");
    }
  }

  String encodeAddressData(Address address) {

    var body = json.encode({
      "name" : address.name,
      "street": address.street,
      "email": address.email,
      "state": address.state,
      "city": address.city,
      "phoneNumber": address.phoneNumber
    });

    return body;
  }

  Future<dynamic> socialLogin(CommonHelper commonHelper, String body) async {

    try {

      SocialLoginModel response = await _apiHelper.socialLogin(body);

      if(response.statusCode == 200) {
  
        _socialSubject.sink.add(response);

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

        if(response.data?.locationName == null) {

          commonHelper.startActivityAndCloseOther(AddLocationActivity(isHome: true));

        } else {

          commonHelper.startActivityAndCloseOther(HomeActivity());
        }

      } else {

        return Future.error(response.data.toString());
      }
      
    } catch (error) {
  
      return Future.error("SomeThing Error");
    }
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

  @override
  void dispose() {
  
    _createOtpSubject.close();
  
    _socialSubject.close();
    
    _subject.close();

    _emailController.close();

    _passwordController.close();
  }
}

mixin LoginValidators {
  
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

          sink.addError('The password must be at least 6 character long.');
        }
      }
  );
}