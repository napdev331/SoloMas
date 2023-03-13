import 'package:flutter/material.dart';

class Constants {
  //Font Sizes
  static const double FONT_MAXIMUM = 18.0;
  static const double FONT_APP_TITLE = 20.0;
  static const double FONT_LOW_SIZE = 8.0;
  static const double FONT_BIG_APP_TITLE = 26.0;
  static const double FONT_TOP = 16.0;
  static const double FONT_MEDIUM = 14.0;
  static const double FONT_LOW = 12.0;
  static const String COUNTRY_CODE = '+1';
  static const String TYPE_NEW_USER = "UR";
  static const String TYPE_FORGOT_PASSWORD = "FP";

  //Public Feeds
  static const String PUBLIC_FEED_TYPE_IMAGE = "image";

  //Button Sizes
  static const double BTN_SIZE = 50.0;
  static const double TF_SIZE = 50.0;

  //Google Maps Api Key
  //static const String API_KEY = 'AIzaSyBWlG-J0cMQBOv8CN1RcDmePChQ7lt9t8U'; //Staging

  static const String API_KEY =
      'AIzaSyAMOoTT8MrZOl2QaJOYtXVuw_DA8ovDk0k'; //Production

  //Shared Preference
  static const String PREF_AUTH_TOKEN = 'pref_auth_token';
  static const String PREF_NAME = 'pref_name';
  static const String PREF_STATUS = 'pref_status';
  static const String PREF_AGE = 'pref_age';
  static const String PREF_ADDRESS = 'pref_user_address';
  static const String PREF_LOC_ADDRESS = 'pref_user_loc_address';
  static const String PREF_EMAIL = 'pref_email';
  static const String PREF_APPLE_USER_NAME = 'pref_apple_name';
  static const String PREF_APPLE_USER_EMAIL = 'pref_apple_email';
  static const String PREF_USER_ID = 'pref_user_id';
  static const String PREF_PROFILE_PIC = 'pref_profile_pic';
  static const String PREF_USER_TYPE = 'pref_user_Type';
  static const String PREF_REFERRAL_CODE = 'pref_referral_code';
  static const String PREF_DEVICE_TOKEN = 'pref_device_token';
  static const String PREF_USER_DATA = 'user_data';
  static const String PREF_INTRODUCTION = 'introduction_screens';
  static const String PREF_LAT = 'lat';
  static const String PREF_LNG = 'lng';
  static const String PREF_CURRENT_ADDRESS = 'PREF_CURRENT_ADDRESS';
  static const String PREF_SEARCH_DATA = 'search_data';

  //Sockets
  static const String SOCKET_CONNECT = "connect";
  static const String SOCKET_DISCONNECT = "disconnect";
  static const String SOCKET_ERROR = "socketErr";
  static const String SOCKET_SEND_MESSAGE = "sendMessage";

  //Road King/Queen
  static const String TYPE_ROAD_KING = "roadKing";
  static const String TYPE_ROAD_QUEEN = "roadQueen";
  static bool isNavigated = false;

  static void printValue(dynamic value) {
    print('print_value:  ' + value.toString());
  }

  GlobalKey<ScaffoldState>? scaffoldKey;
}
