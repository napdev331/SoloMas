import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../../resources_helper/screen_area/scaffold.dart';

class MeetupInfo extends StatefulWidget {
  const MeetupInfo({Key? key}) : super(key: key);

  @override
  State<MeetupInfo> createState() => _MeetupInfoState();
}

class _MeetupInfoState extends State<MeetupInfo> {
  @override
  Widget build(BuildContext context) {
    return SoloScaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: Container(
          margin: EdgeInsets.only(left: DimensHelper.sidesMargin),
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',
                  style: TextStyle(
                      fontFamily: 'Roboto-Regular',
                      color: SoloColor.white,
                      fontWeight: FontWeight.w400))),
        ),
        backgroundColor: SoloColor.chargeBlue,
        actions: [
          Container(
              padding: EdgeInsets.only(right: DimensHelper.searchBarMargin),
              child: TextButton(
                  child: Text('Share',
                      style: TextStyle(
                          fontFamily: 'Roboto-Regular',
                          color: SoloColor.white,
                          fontWeight: FontWeight.w400)),
                  onPressed: () {}))
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: DimensHelper.sidesMarginDouble,
                      top: DimensHelper.textFieldSize),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SoloColor.chargeBlue),
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(right: DimensHelper.halfSides),
                      ),
                      Container(
                          child: Text('John Smith',
                              style: TextStyle(
                                  color: SoloColor.black.withOpacity(0.7),
                                  fontFamily: 'Roboto-Medium',
                                  fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(
                        left: DimensHelper.btnTopMargin,
                        top: DimensHelper.sidesMarginDouble,
                        right: DimensHelper.textFieldSize),
                    child: Text(
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown",
                        style: TextStyle(
                            fontFamily: 'Roboto-Regular',
                            fontSize: 12,
                            color: SoloColor.black.withOpacity(0.57),
                            fontWeight: FontWeight.w400))),
                Container(
                  margin: EdgeInsets.only(
                      left: DimensHelper.btnTopMargin,
                      top: DimensHelper.sidesBtnDouble),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/calendar.svg',
                          color: SoloColor.black, height: 16),
                      Container(
                          margin: EdgeInsets.only(left: DimensHelper.halfSides),
                          child: Text('22 September 2022 to 28 September 2022',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Roboto-Medium',
                                  fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: DimensHelper.btnTopMargin,
                      top: DimensHelper.halfSides),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/location.svg',
                          color: SoloColor.black, height: 16),
                      Container(
                          margin: EdgeInsets.only(left: DimensHelper.halfSides),
                          child: Text('New York',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Roboto-Medium',
                                  fontWeight: FontWeight.w500))),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
