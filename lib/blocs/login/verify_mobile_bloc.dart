import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/activities/home_activity.dart';
import 'package:solomas/activities/registration/add_location_activity.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/sign_up_model.dart';
import 'package:solomas/model/update_mobile_model.dart';
import 'package:solomas/model/verify_otp_model.dart';

import '../bloc.dart';

class VerifyMobileBloc extends Object with OtpValidators implements Bloc {

  BehaviorSubject<VerifyOtpModel> _subject = BehaviorSubject<VerifyOtpModel>();

  BehaviorSubject<SignUpModel> _signSubject = BehaviorSubject<SignUpModel>();

  BehaviorSubject<CreateOtpModel> _createOtpSubject = BehaviorSubject<CreateOtpModel>();

  var _apiHelper = ApiHelper();

  final _otpController = BehaviorSubject<String>();
  
  Function(String) get otpChanged => _otpController.sink.add;
  
  Stream <String> get otpStream =>
      _otpController.stream.transform(_otpValidator);
  
  Stream<String> get otpCheck => ValueConnectableStream(otpStream);

  BehaviorSubject<VerifyOtpModel> get subject => _subject;

  BehaviorSubject<SignUpModel> get signUpSubject => _signSubject;

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

  Future<dynamic> verifyOtp(String body) async {
  
    try {

      VerifyOtpModel response = await _apiHelper.verifyOtp(body);

    if(response.statusCode == 200) {

      _subject.sink.add(response);

      return Future.value(response);

    } else {

      return Future.error(response.data.toString());
    }
  
  } catch (error) {

      throw ("Something Error");
    }
  }

  Future<dynamic> signUpUser(CommonHelper commonHelper, String body) async {

    try {

      SignUpModel response = await _apiHelper.signUp(body);

      if(response.statusCode == 200) {
  
        _signSubject.sink.add(response);

        PrefHelper.setUserId(response.data!.userId.toString());

        PrefHelper.setUserName(response.data!.fullName.toString());

        PrefHelper.setUserName(response.data!.fullName.toString());

        PrefHelper.setUserAge(response.data!.age.toString());

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

      return Future.error("Something Error");
    }
  }

  @override
  void dispose() {
  
    _subject.close();
    
    _otpController.close();

    _signSubject.close();

    _createOtpSubject.close();
  }
}

mixin OtpValidators {
  
  var _otpValidator = StreamTransformer<String, String>.fromHandlers(
      
      handleData: (password, sink) {
        
        if (password.toString().length == 4) {
          
          sink.add(password);

        } else {
          
          sink.addError('Please enter a valid otp');
        }
      }
  );
}