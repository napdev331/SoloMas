import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/blogs/blog_tab.dart';
import 'package:solomas/activities/bottom_tabs/home_tab.dart';
import 'package:solomas/activities/bottom_tabs/menu_tab.dart';
import 'package:solomas/activities/registration/add_location_activity.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/firebase_notificatons.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/resources_helper/colors.dart';

import '../helpers/bottomBar/solo_bottom_bar.dart';
import '../resources_helper/images.dart';
import 'bottom_tabs/events_continents_activity.dart';
import 'bottom_tabs/explore_tab.dart';
import 'bottom_tabs/services_continents_activity.dart';
import 'home/carnival_detail_activity.dart';

class HomeActivity extends StatefulWidget {
  static const routeName = "/homeActivity";
  final int currentIndex;
  final int? exploreIndex;
  final String? blogId;
  final String? blogShareId;
  final String? publicFeedId;
  final bool? scrollMessage, screenOpenedFromDynamicLink;

  HomeActivity(
      {this.currentIndex = 0,
      this.blogId,
      this.exploreIndex,
      this.screenOpenedFromDynamicLink,
      this.publicFeedId,
      this.scrollMessage,
      this.blogShareId});

  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity>
    with WidgetsBindingObserver {
//============================================================
// ** Properties **
//============================================================
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int currentPage = 0;
  GlobalKey bottomNavigationKey = GlobalKey();
  int? _currentIndex;
  CommonHelper? _commonHelper;
  late FlutterLocalNotificationsPlugin fltNotification;
  int? exploreIndexPos;
  List<Widget>? _children;

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    if (widget.screenOpenedFromDynamicLink != true) {
      appKilledDynamicLinks();
      appNotKilledDynamicLink();
    }
    _getAddress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeFcm(context);
    });

    Constants().scaffoldKey = GlobalKey<ScaffoldState>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    if (widget.exploreIndex != null) {
      ExploreTab(exploreIndexPos: 3);
    }

    return WillPopScope(
      onWillPop: () async => await _onBackPressed(),
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
        drawerEdgeDragWidth: 0,
        drawer: DrawerManu(),
        key: Constants().scaffoldKey,
        body: _getPage(currentPage),
        bottomNavigationBar: _stylishBottomBar(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

//============================================================
// ** Main Widgets **
//============================================================

  SoloBottomBar _stylishBottomBar() {
    return SoloBottomBar(
      tabs: [
        TabData(
            imageData: IconsHelper.home,
            title: "HOME",
            onclick: () {
              final SoloBottomBarState fState =
                  bottomNavigationKey.currentState as SoloBottomBarState;
              fState.setPage(2);
            }),
        TabData(
          imageData: IconsHelper.explore,
          title: "EXPLORE",
        ),
        TabData(imageData: IconsHelper.events, title: "EVENTS"),
        TabData(imageData: IconsHelper.services, title: "SERVICES"),
        TabData(imageData: IconsHelper.blog, title: "BLOG")
      ],
      initialSelection: 0,
      key: bottomNavigationKey,
      activeIconColor: SoloColor.white,
      inactiveIconColor: SoloColor.black,
      activeTextColor: SoloColor.black,
      textColor: SoloColor.sonicSilver,
      circleColor: SoloColor.pink,
      onTabChangedListener: (position) {
        setState(() {
          currentPage = position;
        });
      },
    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return HomeTab(
            publicFeedId: widget.publicFeedId,
            scrollMessage: widget.scrollMessage);

      case 1:
        return ExploreTab(exploreIndexPos: widget.exploreIndex);
      case 2:
        return EventsContinentActivity();
      case 3:
        return ServicesContinentActivity();
      case 4:
        return BlogTab(
            blogId: widget.blogId,
            isScroll: widget.scrollMessage,
            blogShareId: widget.blogShareId);
      default:
        return SizedBox();
    }
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget bottomBarIcon(
    String icon,
  ) {
    return Container(
      child: SvgPicture.asset(
        icon,
        width: 30,
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to exit the Solo Mas App?'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'No',
                    style: TextStyle(color: SoloColor.blue),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Yes', style: TextStyle(color: SoloColor.blue)),
                  onPressed: () {
                    SystemNavigator.pop();
                    //   Navigator.of(context).pop(true);
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

//============================================================
// ** Helper Functions **
//============================================================

  void _getAddress() {
    PrefHelper.getUserLocationAddress().then((onValue) {
      setState(() {
        if (onValue == null) {
          _commonHelper?.startActivity(AddLocationActivity(isHome: true));
        }
      });
    });
  }

  void _openChatAdminPage(String carnivalId, String continent) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CarnivalDetailActivity(
                      carnivalId: carnivalId,
                    ),
                fullscreenDialog: false))
        .then((value) {
      if (value) {
        setState(() {});
      }
    });
  }

  void appKilledDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLinkOne = data?.link;
    String carnivalId = deepLinkOne?.queryParameters["CarnivalId"] ?? '';
    String continent = deepLinkOne?.queryParameters["Continent"] ?? '';
    String blogId = deepLinkOne?.queryParameters["blogId"] ?? '';
    String type = deepLinkOne?.queryParameters["type"] ?? '';
    if (deepLinkOne != null) {
      if (type == "blog") {
        _commonHelper?.startActivity(HomeActivity(
          currentIndex: 4,
          screenOpenedFromDynamicLink: true,
          blogShareId: blogId,
        ));
      } else {
        _openChatAdminPage(carnivalId, continent);
      }
    }
  }

  void appNotKilledDynamicLink() {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) async {
      final Uri? deepLink = dynamicLink.link;
      print("deepLink-----" + deepLink.toString());
      String carnivalId = deepLink?.queryParameters["CarnivalId"] ?? '';
      String continent = deepLink?.queryParameters["Continent"] ?? '';
      String blogId = deepLink?.queryParameters["blogId"] ?? '';
      String type = deepLink?.queryParameters["type"] ?? '';

      if (deepLink != null) {
        if (type == "blog") {
          _commonHelper?.startActivity(HomeActivity(
            currentIndex: 4,
            screenOpenedFromDynamicLink: true,
            blogShareId: blogId,
          ));
        } else {
          _openChatAdminPage(carnivalId, continent);
        }
      }
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

//============================================================
// ** Firebase Functions **
//============================================================

  void initializeFcm(BuildContext context) async {
    var firebaseNotifications = FireBaseNotifications(context);
    await openFromTerminatedState();
  }

  Future<dynamic> openFromTerminatedState() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      if (message != null) {
        await _commonHelper?.initIntent(
            message.data['type'] ?? '', message.data['data'] ?? message.data);
      }
      //  redirectScreen(message?.data);
    });
  }
}
