import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/model/notification_model.dart';

import 'constants.dart';

class FireBaseNotifications {
  FirebaseMessaging? _fireBaseMessaging;

  FlutterLocalNotificationsPlugin? localPlugin;

  BuildContext? context;

  CommonHelper? _commonHelper;

  bool isEnable = false;

  Map<String, dynamic>? msgMap;

  NotificationData? _notificationData;

  FireBaseNotifications(this.context) {
    context = context;
    _commonHelper = CommonHelper(context);
    init();
  }

  void init() {
    localPlugin = FlutterLocalNotificationsPlugin();
    _fireBaseMessaging = FirebaseMessaging.instance;
    fireBaseCloudMessagingListeners();
    if (Platform.isIOS) iosPermissions();

    var initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    _fireBaseMessaging?.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    localPlugin?.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) =>
            onSelectNotification(payload.toString()));
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      _commonHelper?.initIntent(
          _notificationData!.type.toString(), msgMap?['data'] ?? msgMap);
    }
  }

  Future _showNotificationWithSound(
      String body, String title, NotificationData json) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'solo_mas_id', 'solo_mas_channel',
        importance: Importance.max, priority: Priority.high);

    var iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(sound: "default", presentAlert: true);

    var platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);

    Constants.printValue("_showNotificationWithSound: ");
    if (Platform.isAndroid) {
      await localPlugin?.show(1, title, body, platformChannelSpecifics,
          payload: '${json.toJson()}');
    }
  }

  _onMessageReceived(RemoteMessage message) {
    String body, title;

    if (Platform.isAndroid) {
      body = message.notification!.body.toString();
      title = message.notification!.title.toString();
      msgMap = message.data;

      _notificationData =
          NotificationData(type: message.data['type'], id: message.data['id']);
    } else {
      title = message.notification!.title.toString();
      body = message.notification!.body.toString();
      msgMap = message.data;
      _notificationData =
          NotificationData(type: message.data['type'], id: message.data['id']);
    }

    _showNotificationWithSound(body, title, _notificationData!);
  }

  _onNotificationClick(RemoteMessage message) {
    String type;

    if (Platform.isIOS) {
      type = message.data['type'];
    } else {
      type = message.data['type'];
    }

    _commonHelper?.initIntent(type, message.data);
  }

  void fireBaseCloudMessagingListeners() {
    print("fireBaseCloudMessagingListeners: ");

    _fireBaseMessaging?.getToken().then((token) {
      print('DEVICE TOKEN: ' + token.toString());
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _onMessageReceived(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onNotificationClick(message);
    });
  }

  void iosPermissions() {
    _fireBaseMessaging?.requestPermission(
      alert: true,
      sound: true,
      announcement: true,
      badge: true,
      provisional: true,
      carPlay: false,
      criticalAlert: false,
    );
  }
}
