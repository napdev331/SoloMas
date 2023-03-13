import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../resources_helper/screen_area/scaffold.dart';

class IntroActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IntroState();
  }
}

class _IntroState extends State<IntroActivity> {
  PageController _pagerController =
      PageController(initialPage: 0, keepPage: false);

  @override
  Widget build(BuildContext context) {
    var _commonHelper = CommonHelper(context);

    void _onSkipTap() {
      PrefHelper.setIntroScreenValue(true);

      _commonHelper.closeActivity();
    }

    Widget _nextButton(int pageNumber) {
      return Container(
        margin: EdgeInsets.only(
            left: _commonHelper.screenWidth * .35,
            right: _commonHelper.screenWidth * .35,
            top: DimensHelper.sidesMargin),
        child: ElevatedButton(
          onPressed: () {
            _pagerController.animateToPage(pageNumber,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: SoloColor.white,
              padding: EdgeInsets.all(0),
              backgroundColor: SoloColor.blue,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DimensHelper.sidesMargin))),
          child: Container(
            height: 35,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(DimensHelper.halfSides))),
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Center(
              child: Text("Next".toUpperCase(),
                  style: TextStyle(fontSize: Constants.FONT_MEDIUM)),
            ),
          ),
        ),
      );
    }

    Widget _doneButton() {
      return Container(
        margin: EdgeInsets.only(
            left: _commonHelper.screenWidth * .35,
            right: _commonHelper.screenWidth * .35,
            top: DimensHelper.sidesMargin),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: SoloColor.white,
            padding: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DimensHelper.halfSides)),
            backgroundColor: SoloColor.pink,
          ),
          onPressed: () {
            _onSkipTap();
          },
          child: Container(
            height: 35,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(DimensHelper.halfSides))),
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Center(
              child: Text("Done".toUpperCase(),
                  style: TextStyle(fontSize: Constants.FONT_MEDIUM)),
            ),
          ),
        ),
      );
    }

    Widget tabOne() {
      return Container(
        height: _commonHelper.screenHeight,
        width: _commonHelper.screenWidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage("assets/images/intro_bg.png"),
                fit: BoxFit.fill)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: _commonHelper.screenHeight * .68,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.asset("assets/images/intro_one.png",
                            height: _commonHelper.screenHeight * .55)
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: DimensHelper.sidesMargin),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Meet other",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.normal,
                                  color: SoloColor.black)),
                          TextSpan(
                              text: " solo masqueraders ",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.bold,
                                  color: SoloColor.pink)),
                          TextSpan(
                              text: "\non the road.",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.normal,
                                  color: SoloColor.black)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: DotsIndicator(
                      dotsCount: 3,
                      position: 0,
                      decorator: DotsDecorator(
                        color: SoloColor.silverSand,
                        activeColor: SoloColor.pink,
                      ),
                    ),
                  ),
                  _nextButton(1)
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  _onSkipTap();
                },
                child: Container(
                  margin: EdgeInsets.only(top: DimensHelper.sideDoubleMargin),
                  padding: EdgeInsets.all(DimensHelper.sidesMarginDouble),
                  child: Text('SKIP',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: Constants.FONT_MEDIUM,
                          color: SoloColor.spanishGray)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget tabTwo() {
      return Container(
        height: _commonHelper.screenHeight,
        width: _commonHelper.screenWidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage("assets/images/intro_bg.png"),
                fit: BoxFit.fill)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: _commonHelper.screenHeight * .68,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Image.asset("assets/images/intro_two.png",
                              height: _commonHelper.screenHeight * .55)
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: DimensHelper.sidesMargin),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text:
                                  "Join groups, make plans, and get recommendations from ",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.normal,
                                  color: SoloColor.black)),
                          TextSpan(
                              text: "Carnival veterans.",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.bold,
                                  color: SoloColor.pink)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: DotsIndicator(
                      dotsCount: 3,
                      position: 1,
                      decorator: DotsDecorator(
                        color: SoloColor.silverSand,
                        activeColor: SoloColor.pink,
                      ),
                    ),
                  ),
                  _nextButton(2)
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  _onSkipTap();
                },
                child: Container(
                  margin: EdgeInsets.only(top: DimensHelper.sideDoubleMargin),
                  padding: EdgeInsets.all(DimensHelper.sidesMarginDouble),
                  child: Text('SKIP',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: Constants.FONT_MEDIUM,
                          color: SoloColor.spanishGray)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget tabThree() {
      return Container(
        height: _commonHelper.screenHeight,
        width: _commonHelper.screenWidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage("assets/images/intro_bg.png"),
                fit: BoxFit.fill)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: _commonHelper.screenHeight * .68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/intro_three.png",
                            height: _commonHelper.screenHeight * .55),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: DimensHelper.sidesMargin),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Find other",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.normal,
                                  color: SoloColor.black)),
                          TextSpan(
                              text: " attendees ",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.bold,
                                  color: SoloColor.pink)),
                          TextSpan(
                              text: "\nin your area.",
                              style: TextStyle(
                                  fontSize: Constants.FONT_MAXIMUM,
                                  fontWeight: FontWeight.normal,
                                  color: SoloColor.black)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: DotsIndicator(
                      dotsCount: 3,
                      position: 2,
                      decorator: DotsDecorator(
                        color: SoloColor.silverSand,
                        activeColor: SoloColor.pink,
                      ),
                    ),
                  ),
                  _doneButton()
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  _onSkipTap();
                },
                child: Container(
                  margin: EdgeInsets.only(top: DimensHelper.sideDoubleMargin),
                  padding: EdgeInsets.all(DimensHelper.sidesMarginDouble),
                  child: Text('SKIP',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: Constants.FONT_MEDIUM,
                          color: SoloColor.spanishGray)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SoloScaffold(
      body: Container(
        child: PageView(
          physics: BouncingScrollPhysics(),
          controller: _pagerController,
          children: [
            tabOne(),
            tabTwo(),
            tabThree(),
          ],
        ),
      ),
    );
  }
}
