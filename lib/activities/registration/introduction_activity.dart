import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/resources_helper/colors.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    var _commonHelper = CommonHelper(context);

    const bodyStyle = TextStyle(fontSize: Constants.FONT_MAXIMUM);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: Constants.FONT_BIG_APP_TITLE, fontWeight: FontWeight.w600),
      bodyTextStyle: bodyStyle,
      pageColor: Colors.white,
      imageFlex: 2,
      imagePadding: EdgeInsets.zero,
    );

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: IntroductionScreen(
        key: introKey,
        pages: [
          PageViewModel(
            title: "",
            bodyWidget: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "Discover",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.normal,
                          color: SoloColor.black)),
                  TextSpan(
                      text: " Masqueraders ",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.bold,
                          color: SoloColor.sunsetRed)),
                  TextSpan(
                      text: "in your area.",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.normal,
                          color: SoloColor.black)),
                ],
              ),
            ),
            image: Align(
              alignment: Alignment.center,
              child: Image.asset('assets/images/intro_one.png', width: 350),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "",
            bodyWidget: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text:
                          "Join groups, Make plans and get recommedations from ",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.normal,
                          color: SoloColor.black)),
                  TextSpan(
                      text: "Carnival veterans.",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.bold,
                          color: SoloColor.sunsetRed)),
                ],
              ),
            ),
            image: Center(
              child: Image.asset('assets/images/intro_two.png', width: 350),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "",
            bodyWidget: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "Meet other solo",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.normal,
                          color: SoloColor.black)),
                  TextSpan(
                      text: " Masqueraders ",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.bold,
                          color: SoloColor.sunsetRed)),
                  TextSpan(
                      text: "on the Road.",
                      style: TextStyle(
                          fontSize: Constants.FONT_MAXIMUM,
                          fontWeight: FontWeight.normal,
                          color: SoloColor.black)),
                ],
              ),
            ),
            image: Center(
              child: Image.asset('assets/images/intro_three.png', width: 350),
            ),
            decoration: pageDecoration,
          ),
        ],
        onDone: () {
          PrefHelper.setIntroScreenValue(true);

          _commonHelper.closeActivity();
        },
        skipFlex: 0,
        nextFlex: 0,
        next: Text('Next',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: SoloColor.sunsetRed)),
        done: Text('Done',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: SoloColor.sunsetRed)),
        skip: Text('Skip',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: SoloColor.sunsetRed)),
        onSkip: () {
          PrefHelper.setIntroScreenValue(true);

          _commonHelper.closeActivity();
        },
        dotsDecorator: DotsDecorator(
          size: Size(10.0, 10.0),
          activeColor: SoloColor.sunsetRed,
          color: SoloColor.silverSand,
          activeSize: Size(10.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}
