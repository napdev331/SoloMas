import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';

class AttendersActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AttendersState();
  }
}

class _AttendersState extends State<AttendersActivity> {
  CommonHelper? _commonHelper;

  @override
  void initState() {
    super.initState();
  }

  Widget profileImage() {
    return ClipOval(
        child: CachedNetworkImage(
      imageUrl: "http://homepages.cae.wisc.edu/~ece533/images/cat.png",
      height: 70,
      width: 70,
      fit: BoxFit.cover,
      placeholder: (context, url) => imagePlaceHolder(),
      errorWidget: (context, url, error) => imagePlaceHolder(),
    ));
  }

  Widget peopleDetailCard() {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          top: DimensHelper.halfSides),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: DimensHelper.halfSides),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DimensHelper.sidesMargin)),
              elevation: 3.0,
              child: Container(
                margin: EdgeInsets.only(left: 80),
                padding: EdgeInsets.all(DimensHelper.sidesMargin),
                child: Row(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: _commonHelper?.screenWidth * .49,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('aanya Jone'.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: SoloColor.black,
                                          fontSize: Constants.FONT_TOP)),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: DimensHelper.smallSides),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Image.asset(
                                                "assets/images/ic_band_user.png",
                                                height: 20),
                                          ),
                                          TextSpan(
                                              text: StringHelper.dailyNightmare,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: SoloColor.spanishGray,
                                                  fontSize:
                                                      Constants.FONT_MEDIUM)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          child: Image.asset("assets/images/ic_chat_black.png"),
                        ))
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                right: DimensHelper.sidesMargin),
            child: profileImage(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: AppBar(
        backgroundColor: SoloColor.blue,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _commonHelper?.closeActivity();
              },
              child: Container(
                width: 25,
                height: 25,
                alignment: Alignment.centerLeft,
                child: Image.asset('images/back_arrow.png'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(StringHelper.attendees.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: _commonHelper?.screenHeight,
            width: _commonHelper?.screenWidth,
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return peopleDetailCard();
                }),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
