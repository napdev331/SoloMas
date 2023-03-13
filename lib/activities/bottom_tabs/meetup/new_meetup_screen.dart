import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/meetup/meetup_info.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../../resources_helper/screen_area/scaffold.dart';

class NewMeetupScreen extends StatefulWidget {
  const NewMeetupScreen({Key? key}) : super(key: key);

  @override
  State<NewMeetupScreen> createState() => _NewMeetupScreenState();
}

class _NewMeetupScreenState extends State<NewMeetupScreen> {
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
        centerTitle: true,
        title: Text('NEW MEETUP',
            style: TextStyle(
                fontFamily: 'Poppins-Regular',
                color: SoloColor.white,
                fontWeight: FontWeight.w400)),
        backgroundColor: SoloColor.chargeBlue,
        actions: [
          Container(
              padding: EdgeInsets.only(right: DimensHelper.searchBarMargin),
              child: TextButton(
                  child: Text('Share',
                      style: TextStyle(
                          fontFamily: 'Roboto-Regular',
                          color: SoloColor.white.withOpacity(0.6),
                          fontWeight: FontWeight.w400)),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MeetupInfo()));
                  }))
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
                      top: DimensHelper.sidesMarginDouble),
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
                        top: DimensHelper.sidesMarginDouble),
                    child: Text('Tell us what Your Meetup is all about',
                        style: TextStyle(
                            fontFamily: 'Roboto-Regular',
                            fontSize: 12,
                            color: SoloColor.black.withOpacity(0.34),
                            fontWeight: FontWeight.w400)))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
