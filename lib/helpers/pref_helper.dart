import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solomas/helpers/constants.dart';

class PrefHelper {
  static Future<String?> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.PREF_AUTH_TOKEN) ?? null;
  }

  static Future<bool> setAuthToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(Constants.PREF_AUTH_TOKEN, value);
  }

  static Future<String?> getDeviceToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.PREF_DEVICE_TOKEN) ?? null;
  }

  static Future<bool> setDeviceToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(Constants.PREF_DEVICE_TOKEN, value);
  }

  static Future<String?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.PREF_USER_DATA) ?? null;
  }

  static Future<bool> setUserData(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_USER_DATA, value);
  }

  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_USER_ID) ?? null;
  }

  static Future<bool> setUserId(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_USER_ID, value);
  }

  static Future<String?> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_NAME) ?? null;
  }

  static Future<String?> getUserStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_STATUS) ?? null;
  }

  static Future<bool> setUserName(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_NAME, value);
  }

  static Future<bool> setUserStatus(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_STATUS, value);
  }

  static Future<bool> setUserAge(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_AGE, value);
  }

  static Future<String?> getUserAge() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_AGE) ?? null;
  }

  static Future<String?> getUserAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_ADDRESS) ?? null;
  }

  static Future<bool> setUserAddress(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_ADDRESS, value);
  }

  static Future<String?> getUserLocationAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_LOC_ADDRESS) ?? null;
  }

  static Future<bool> setUserLocationAddress(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_LOC_ADDRESS, value);
  }

  static Future<String?> getUserProfilePic() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_PROFILE_PIC) ?? null;
  }

  static Future<bool> setUserProfilePic(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_PROFILE_PIC, value);
  }

  static Future<bool> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(Constants.PREF_USER_TYPE) ?? false;
  }

  static Future<bool> setUserType(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(Constants.PREF_USER_TYPE, value);
  }

  static Future<String?> getReferralCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_REFERRAL_CODE) ?? null;
  }

  static Future<bool> setReferralCode(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_REFERRAL_CODE, value);
  }

  static Future<bool> setIntroScreenValue(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(Constants.PREF_INTRODUCTION, value);
  }

  static Future<bool> contains(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(key);
  }

  static Future<Future<bool>> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.clear();
  }

  static Future<bool> setLat(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setDouble(Constants.PREF_LAT, value);
  }

  static Future<double> getLat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getDouble(Constants.PREF_LAT) ?? 0;
  }

  static Future<bool> setLng(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setDouble(Constants.PREF_LNG, value);
  }

  static Future<double> getLng() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getDouble(Constants.PREF_LNG) ?? 0;
  }

  static Future<bool> setCurrentAddress(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Constants.PREF_CURRENT_ADDRESS, value);
  }

  static Future<String?> getCurrentAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_CURRENT_ADDRESS) ?? null;
  }

  static Future<bool> setSearchData(String value) async {
    print("heelllllllllllllllllo");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("hiiigetsearchcallset" + value);

    return prefs.setString(Constants.PREF_SEARCH_DATA, value);
  }

  static Future<String?> getSearchData() async {
    print("getsearchdatacalled");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Constants.PREF_SEARCH_DATA) ?? null;
  }
}
