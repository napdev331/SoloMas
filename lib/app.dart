import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/common_widget.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/images.dart';
import 'package:solomas/resources_helper/text_styles.dart';

import 'activities/home_activity.dart';
import 'activities/registration/login_activity.dart';
import 'helpers/common_helper.dart';
import 'helpers/constants.dart';
import 'helpers/pref_helper.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: SoloColor.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Solo Mas',
        darkTheme:
            ThemeData(brightness: Brightness.light, primarySwatch: Colors.grey),
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        navigatorKey: navigatorKey,
        home: FutureBuilder<String?>(
          future: PrefHelper.getAuthToken(),
          builder: (buildContext, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return HomeActivity();
            } else {
              return LoginActivity();
            }
          },
        ));
  }
}

class InstaProfilePage extends StatefulWidget {
  @override
  _InstaProfilePageState createState() => _InstaProfilePageState();
}

class _InstaProfilePageState extends State<InstaProfilePage> {
  late CommonHelper _commonHelper;
  double get randHeight => Random().nextInt(100).toDouble();

  late List<Widget> _randomChildren;

  List<Widget> _randomHeightWidgets(BuildContext context) {
    _randomChildren = [
      SizedBox(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: _commonHelper?.screenHeight * .25,
                  child: CachedNetworkImage(
                    width: _commonHelper?.screenWidth,
                    imageUrl:
                        "https://images.unsplash.com/photo-1670979314026-7c0c4367c8b7?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80",
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Container(color: SoloColor.waterBlue),
                  ),
                ),
                Container(
                  width: _commonHelper?.screenWidth,
                  padding: EdgeInsets.only(top: 2.5),
                  child: appBar(),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: _commonHelper?.screenHeight * .175,
                      left: _commonHelper?.screenHeight * .013),
                  alignment: Alignment.topLeft,
                  child: profileImage(),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: _commonHelper?.screenHeight * .32,
                      bottom: DimensHelper.sidesMargin),
                  alignment: Alignment.center,
                  width: _commonHelper?.screenWidth,
                  child: infoCard(),
                ),
              ],
            ),
          ],
        ),
      )
    ];

    return _randomChildren;
  }

  Widget infoCard() {
    // _aList!.response!.locationName.toString();
    // var split = _aList!.response!.locationName.toString().split(",");
    // var splitTwo = split[3];
    // var splitThree = split[4];
    // var finalLocationString = splitTwo + "," + splitThree;

    return Column(
      children: [
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    right: DimensHelper.sidesMarginDouble,
                  ),
                  alignment: Alignment.topLeft,
                  child: Text("usermame",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: SoloStyle.darkBlackW700MaxTitle),
                ),
                Row(
                  children: [
                    Image.asset(
                      IconsHelper.ic_locationPin,
                      width: _commonHelper!.screenWidth * 0.05,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 6,
                        right: 7,
                      ),
                      alignment: Alignment.topRight,
                      child: Text(
                        "location string",
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: SoloColor.spanishGray,
                            fontWeight: FontWeight.normal,
                            fontSize: Constants.FONT_TOP),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SafeArea(
      child: Scaffold(
        // Persistent AppBar that never scrolls

        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            // allows you to build a list of elements that would be scrolled away till the body reached the top
            headerSliverBuilder: (context, _) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate(
                    _randomHeightWidgets(context),
                  ),
                ),
              ];
            },
            // You tab view goes here
            body: Column(
              children: <Widget>[
                TabBar(
                  tabs: [
                    Tab(text: 'A'),
                    Tab(text: 'B'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 3,
                        children: Colors.primaries.map((color) {
                          return Container(color: color, height: 150.0);
                        }).toList(),
                      ),
                      ListView(
                        padding: EdgeInsets.zero,
                        children: Colors.primaries.map((color) {
                          return Container(color: color, height: 150.0);
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Container(
      child: Stack(
        children: [
          Visibility(
            visible: true,
            child: GestureDetector(
              onTap: () {
                //_commonHelper.closeActivity();
                Navigator.pop(context, true);
              },
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.only(
                      left: DimensHelper.sidesMargin,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Image.asset(IconsHelper.back_with_whightbg),
                  )),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                  height: 50,
                  width: 50,
                  padding: EdgeInsets.only(right: DimensHelper.sidesMargin),
                  alignment: Alignment.centerRight,
                  child: Image.asset(IconsHelper.ic_more)),
            ),
          )
        ],
      ),
    );
  }

  posttab() {
    return Text("this is the tab");
  }

  Widget profileImage() {
    return Container(
      alignment: Alignment.topLeft,
      height: _commonHelper.screenHeight * .24,
      width: _commonHelper.screenHeight * .24,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(new Radius.circular(55.0)),
              ),
              height: _commonHelper.screenHeight * .14,
              width: _commonHelper.screenHeight * .14,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                    child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: _commonHelper.screenHeight * .13,
                  width: _commonHelper.screenHeight * .13,
                  imageUrl:
                      "https://images.unsplash.com/photo-1669383488518-3f367058d9db?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=447&q=80",
                  placeholder: (context, url) => imagePlaceHolder(),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                )),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  margin: EdgeInsets.only(left: DimensHelper.sidesMarginDouble),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(DimensHelper.sidesMarginDouble)),
                      color: SoloColor.black),
                  child: Image.asset('images/ic_camera_white.png')),
            ),
          ),
        ],
      ),
    );
  }
}
