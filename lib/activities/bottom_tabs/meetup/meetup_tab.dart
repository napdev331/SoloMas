import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solomas/activities/bottom_tabs/meetup/meetup_profile_screen.dart';
import 'package:solomas/activities/bottom_tabs/meetup/new_meetup_screen.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../../resources_helper/screen_area/scaffold.dart';

class MeetupTab extends StatefulWidget {
  const MeetupTab({Key? key}) : super(key: key);

  @override
  State<MeetupTab> createState() => _MeetupTabState();
}

class _MeetupTabState extends State<MeetupTab> {
  @override
  Widget build(BuildContext context) {
    return SoloScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('MEETUP',
            style: TextStyle(
                fontFamily: 'Poppins-Regular',
                color: SoloColor.white,
                fontWeight: FontWeight.w400)),
        backgroundColor: SoloColor.chargeBlue,
        actions: [
          Container(
              padding: EdgeInsets.only(right: DimensHelper.searchBarMargin),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewMeetupScreen()));
                },
                child: SvgPicture.asset('assets/images/add.svg'),
              ))
        ],
      ),
      body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MeetupProfileScreen()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                    alignment: Alignment.topLeft,
                    color: SoloColor.white,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: DimensHelper.sidesMargin,
                              bottom: DimensHelper.sidesMargin),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: SoloColor.chargeBlue),
                                    width: 40,
                                    height: 40,
                                    margin: EdgeInsets.only(
                                        left: DimensHelper.sidesMargin,
                                        right: DimensHelper.halfSides),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(
                                              bottom: DimensHelper.smallSides),
                                          child: Text('Jennifer Lawrence',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto-Medium',
                                                  fontWeight:
                                                      FontWeight.w500))),
                                      Container(
                                          child: Text('Tue,16 Sep2022',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto-Regular',
                                                  color: SoloColor.taupeGray,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12))),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    right: DimensHelper.sidesMargin),
                                child: SvgPicture.asset(
                                    'assets/images/ic_three_dots.svg',
                                    height: 16),
                              )
                            ],
                          ),
                        ),
                        Container(height: 150, color: SoloColor.lightSilver),
                        Container(
                            width: double.infinity,
                            height: 35,
                            color: SoloColor.chargeBlue,
                            child: Center(
                              child: Text(
                                'Tue,16 Sep2022',
                                style: TextStyle(
                                    fontFamily: 'Roboto-Regular',
                                    color: SoloColor.white,
                                    fontWeight: FontWeight.w400),
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(
                              left: DimensHelper.sidesMargin,
                              bottom: DimensHelper.sidesMargin,
                              top: DimensHelper.sidesMargin),
                          alignment: Alignment.centerLeft,
                          child: Text('Hey',
                              style: TextStyle(
                                  fontFamily: 'Roboto-Medium',
                                  color: SoloColor.black,
                                  fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
