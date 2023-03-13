import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solomas/activities/bottom_tabs/meetup/new_meetup_screen.dart';

import '../../../resources_helper/colors.dart';
import '../../../resources_helper/dimens.dart';
import '../../../resources_helper/screen_area/scaffold.dart';

class MeetupProfileScreen extends StatefulWidget {
  const MeetupProfileScreen({Key? key}) : super(key: key);

  @override
  State<MeetupProfileScreen> createState() => _MeetupProfileScreenState();
}

class _MeetupProfileScreenState extends State<MeetupProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SoloScaffold(
        appBar: AppBar(
          leading: Container(
            alignment: Alignment.topLeft,
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(DimensHelper.sidesMargin),
                  child: Image.asset('images/blackarrow_black.png',
                      color: SoloColor.white),
                )),
          ),
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
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: DimensHelper.btnTopMargin),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(
                                        bottom: DimensHelper.smallSides),
                                    child: Text('Jennifer Lawrence',
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Medium',
                                            fontWeight: FontWeight.w500))),
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
                          margin:
                              EdgeInsets.only(right: DimensHelper.sidesMargin),
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
                        top: DimensHelper.sidesMargin,
                        right: DimensHelper.sidesMargin),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text('Hey',
                              style: TextStyle(
                                  color: SoloColor.black,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto-Regular')),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: DimensHelper.halfSides,
                              bottom: DimensHelper.halfSides),
                          child: Text(
                              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown ",
                              style: TextStyle(
                                  fontFamily: 'Roboto-Regular',
                                  color: SoloColor.black.withOpacity(0.77),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12)),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              bottom: DimensHelper.searchBarMargin),
                          child: Text('16 Sep2022',
                              style: TextStyle(
                                  color: SoloColor.black,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto-Medium')),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/Star.svg',
                                height: 10),
                            Text('2 Interested',
                                style: TextStyle(
                                    fontFamily: 'Roboto-Regular',
                                    color: SoloColor.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10)),
                            Container(
                                margin: EdgeInsets.only(
                                    left: DimensHelper.smallSides),
                                child:
                                    SvgPicture.asset('assets/images/Tick.svg'),
                                height: 10),
                            Text('0 Going',
                                style: TextStyle(
                                    fontFamily: 'Roboto-Regular',
                                    color: SoloColor.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10)),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                top: DimensHelper.halfSides,
                                bottom: DimensHelper.halfSides),
                            child: Divider(
                                color: SoloColor.spanishGray.withOpacity(0.2))),
                        Container(
                          margin:
                              EdgeInsets.only(bottom: DimensHelper.sidesMargin),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      SvgPicture.asset(
                                          "assets/images/star-copy.svg"),
                                      Text('Interested',
                                          style: TextStyle(
                                              fontFamily: 'Roboto-Regular',
                                              color: SoloColor.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10)),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: DimensHelper.sidesMargin,
                                        right: DimensHelper.sidesMargin),
                                    child: Column(
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/tick-circle.svg'),
                                        Text('Going',
                                            style: TextStyle(
                                                fontFamily: 'Roboto-Regular',
                                                color: SoloColor.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SvgPicture.asset(
                                          'assets/images/comment.svg',
                                          height: 14),
                                      Text('Comment',
                                          style: TextStyle(
                                              fontFamily: 'Roboto-Regular',
                                              color: SoloColor.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10)),
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    right: DimensHelper.sidesMargin),
                                child: Column(
                                  children: [
                                    SvgPicture.asset('assets/images/share.svg'),
                                    Text('Share',
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: SoloColor.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
