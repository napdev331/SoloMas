import 'package:flutter/material.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';

class SoloSize {
  static const double max = 18.0;
  static const double small_max = 17.0;
  static const double title = 20.0;
  static const double max_title = 22.0;
  static const double big_title = 26.0;
  static const double top = 16.0;
  static const double topXs = 15.0;
  static const double medium = 14.0;
  static const double medium_xs = 13.0;
  static const double low = 12.0;
  static const double lower = 10.0;
  static const double extraSmall = 9.0;
  static const double extraLarge = 40.0;
}

class SoloStyle {
  //============================================================
// ** SOLO_MAS FORMAT AND NAME **
//============================================================

/*

//===================
// ** FORMAT **
//===================
  static const TextStyle demoStyle =
  TextStyle(
    color: [COLOR NAME],
    fontWeight: [FONT WEIGHT],
    fontSize:[FONT SIZE],
    fontFamily: [FONT FAMILY]
      [OTHER PROPERTIES]
  );

//===================
// ** NAME **
//===================
  static const TextStyle blackBold18 =
  TextStyle(
  color:DcgColor.BLACK,
  fontWeight:FontWeight.bold,
  fontSize:18,
  fontFamily:'ROBOTO'
  );

  Note: if you want to change some textStyle properties then you also need to change
        style name with [Shift + F6] as per TextStyle properties.
*/
  static TextStyle greyNormalTopRoboto = TextStyle(
      color: SoloColor.lightGrey200,
      fontWeight: FontWeight.normal,
      fontSize: SoloSize.top,
      fontFamily: 'Roboto');

  static TextStyle greyNormalMediumRoboto = TextStyle(
      color: SoloColor.lightGrey200,
      fontWeight: FontWeight.normal,
      fontSize: SoloSize.medium,
      fontFamily: 'Roboto');

  static TextStyle blackBoldMediumRoboto = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.bold,
      fontSize: SoloSize.medium,
      fontFamily: 'Roboto');

  static TextStyle blackLower = TextStyle(
    color: SoloColor.black,
    fontSize: SoloSize.medium,
  );

  static TextStyle blackBoldLow = TextStyle(
    color: SoloColor.black,
    fontWeight: FontWeight.bold,
    fontSize: SoloSize.low,
  );

  static TextStyle whiteBoldTop = TextStyle(
    color: SoloColor.white,
    fontWeight: FontWeight.bold,
    fontSize: SoloSize.top,
  );

  static TextStyle whiteSmall = TextStyle(
    color: SoloColor.white,
    fontSize: SoloSize.low,
  );

  static TextStyle drawerBottom = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: Constants.FONT_MEDIUM,
      color: SoloColor.spanishGray);

  static TextStyle drawerMiddle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: Constants.FONT_TOP,
    color: SoloColor.silverSand,
  );
  static TextStyle blackLetterSpacing = TextStyle(fontSize: 13);

  static TextStyle blackW700Blow = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w700,
      fontSize: SoloSize.low,
      fontFamily: 'Roboto');
  static TextStyle blackW900BMedium = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w900,
      fontSize: SoloSize.title,
      fontFamily: 'Roboto');

  static TextStyle profileDesc = TextStyle(
      fontSize: Constants.FONT_MEDIUM,
      fontWeight: FontWeight.w500,
      color: SoloColor.spanishGray);

  static TextStyle profileTitle = TextStyle(
      fontSize: Constants.FONT_MEDIUM,
      fontWeight: FontWeight.w700,
      color: SoloColor.spanishGray);

  static TextStyle titleBlack = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w500,
      fontSize: Constants.FONT_BIG_APP_TITLE);

  static TextStyle mediumGrey = TextStyle(
      color: SoloColor.spanishGray,
      fontWeight: FontWeight.w500,
      fontSize: Constants.FONT_MEDIUM);

  static TextStyle topGrey = TextStyle(
      color: SoloColor.spanishGray,
      fontWeight: FontWeight.normal,
      fontSize: Constants.FONT_MEDIUM);

  static TextStyle maxBlue = TextStyle(
      color: SoloColor.blue,
      fontSize: Constants.FONT_MAXIMUM,
      fontWeight: FontWeight.bold);

  static TextStyle settingHeaders = TextStyle(
      color: SoloColor.spanishGray,
      fontSize: Constants.FONT_TOP,
      fontWeight: FontWeight.w500);

  // new

  static TextStyle whiteW500Medium = TextStyle(
    color: SoloColor.white,
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.medium,
  );

  static TextStyle lightGrey200W700low = TextStyle(
    color: SoloColor.lightGrey200,
    fontWeight: FontWeight.w400,
    fontSize: SoloSize.low,
  );

  static TextStyle darkBlackW800SmallMax = TextStyle(
    color: SoloColor.black.withOpacity(0.8),
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.topXs,
  );
  static TextStyle blackW500TopXs = TextStyle(
    color: SoloColor.black.withOpacity(0.8),
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.topXs,
  );
  static TextStyle blackW500Top = TextStyle(
    color: SoloColor.black.withOpacity(0.8),
    fontWeight: FontWeight.w900,
    fontSize: SoloSize.medium,
  );
  static TextStyle blackW700Top = TextStyle(
    color: SoloColor.black.withOpacity(0.8),
    fontWeight: FontWeight.w700,
    fontSize: SoloSize.top,
  );
  static TextStyle graniteGrayW500Medium = TextStyle(
    color: SoloColor.graniteGray.withOpacity(0.7),
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.medium,
  );
  static TextStyle blueAssentW500Medium = TextStyle(
    color: SoloColor.blueAssent,
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.medium,
  );

  static TextStyle transparentW500MediumXs = TextStyle(
    color: Colors.transparent,
    fontWeight: FontWeight.w400,
    fontSize: SoloSize.low,
    shadows: [Shadow(color: Colors.black, offset: Offset(0, -5))],
    decoration: TextDecoration.underline,
    decorationColor: SoloColor.pink,
    decorationThickness: 2,
    decorationStyle: TextDecorationStyle.solid,
  );

  static TextStyle blackNormalMedium = TextStyle(
    color: SoloColor.black,
    fontWeight: FontWeight.normal,
    fontSize: SoloSize.medium,
  );

  static TextStyle black54W500SmallMax = TextStyle(
    color: SoloColor.jet,
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.small_max,
  );
  static TextStyle graniteGrayW500TopXs = TextStyle(
    color: SoloColor.graniteGray.withOpacity(0.8),
    fontWeight: FontWeight.w400,
    fontSize: SoloSize.medium,
  );

  static TextStyle lightGrey200W600low = TextStyle(
    color: SoloColor.lightGrey200.withOpacity(0.8),
    fontWeight: FontWeight.normal,
    fontSize: SoloSize.low,
  );

  static TextStyle lightGrey200W600MediumXs = TextStyle(
    color: SoloColor.lightGrey200.withOpacity(0.8),
    fontWeight: FontWeight.normal,
    fontSize: SoloSize.medium_xs,
  );
  static TextStyle lightGrey200W500SmallMax = TextStyle(
    color: SoloColor.graniteGray,
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.small_max,
  );
  static TextStyle taupeGrayW600MediumXs = TextStyle(
    color: SoloColor.taupeGray,
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.medium_xs,
  );
  static TextStyle taupeGrayW500MediumXs = TextStyle(
    color: SoloColor.taupeGray.withOpacity(0.8),
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.medium_xs,
  );

  static TextStyle blackBoldMedium = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: Constants.FONT_MEDIUM,
  );

  static TextStyle lightGrey200W500Top = TextStyle(
    color: SoloColor.spanishLightGrey.withOpacity(0.9),
    fontWeight: FontWeight.normal,
    fontSize: SoloSize.topXs,
  );
  static TextStyle lightGrey200normalTop = TextStyle(
    color: SoloColor.spanishLightGrey.withOpacity(0.9),
    fontWeight: FontWeight.normal,
    fontSize: SoloSize.top,
  );
  static TextStyle darkBlackW700MaxTitle = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w700,
      fontSize: SoloSize.title,
      fontFamily: 'ROBOTO');
  static TextStyle whiteW700MaxTitle = TextStyle(
      color: SoloColor.white,
      fontWeight: FontWeight.w700,
      fontSize: SoloSize.title,
      fontFamily: 'ROBOTO');

  static TextStyle darkBlackW700MaxRob = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w600,
      fontSize: SoloSize.topXs,
      fontFamily: 'ROBOTO');

  static TextStyle lightGrey200W700Medium = TextStyle(
    color: SoloColor.lightGrey200.withOpacity(0.8),
    fontWeight: FontWeight.w700,
    fontSize: SoloSize.medium,
  );

  static TextStyle whiteW500Low = TextStyle(
      color: SoloColor.white,
      fontWeight: FontWeight.w500,
      fontSize: SoloSize.low);

  static TextStyle blackW900TopXs = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w900,
      fontSize: SoloSize.topXs);

  static TextStyle blackW900Top = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w900,
      fontSize: SoloSize.medium);

  static TextStyle lightGrey200W500Medium = TextStyle(
    color: SoloColor.lightGrey200.withOpacity(0.8),
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.medium,
  );

  static TextStyle lightGrey20005W500Medium = TextStyle(
    color: SoloColor.lightGrey200.withOpacity(0.6),
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.low,
  );

  static TextStyle jetW500SmallMax = TextStyle(
    color: SoloColor.jet,
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.small_max,
  );
  static TextStyle blueW500FontLow = TextStyle(
    color: SoloColor.blue,
    fontWeight: FontWeight.w500,
    fontSize: Constants.FONT_LOW,
  );
  static TextStyle lightGrey200W400Low = TextStyle(
    color: SoloColor.lightGrey200.withOpacity(0.7),
    fontWeight: FontWeight.w400,
    fontSize: SoloSize.low,
  );

  static TextStyle blackMediumRoboto = TextStyle(
      decoration: TextDecoration.none,
      color: SoloColor.lightGrey200,
      fontWeight: FontWeight.normal,
      fontSize: SoloSize.medium,
      fontFamily: 'Roboto');

  static TextStyle blackBoldMax = TextStyle(
      decoration: TextDecoration.none,
      color: SoloColor.black,
      fontWeight: FontWeight.bold,
      fontSize: SoloSize.max,
      fontFamily: 'Roboto');

  static TextStyle blackW500Title = TextStyle(
    color: SoloColor.black,
    fontWeight: FontWeight.w500,
    fontSize: SoloSize.title,
  );

  static TextStyle darkBlackW500title = TextStyle(
      color: SoloColor.graniteGray,
      fontWeight: FontWeight.w500,
      fontSize: SoloSize.title);
  static TextStyle darkBlackW70020Rob = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w600,
      fontSize: 15,
      fontFamily: 'Roboto');

  static TextStyle darkBlackW700TopRob = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w700,
      fontSize: SoloSize.top,
      fontFamily: 'Roboto');

  static TextStyle darkBlackW70015Rob = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      fontFamily: 'Roboto');
  static TextStyle darkBlackW700MediumRob = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      fontFamily: 'Roboto');
  static TextStyle smokeWhiteW70010Rob = TextStyle(
      color: SoloColor.white,
      fontWeight: FontWeight.bold,
      fontSize: 8,
      // fontSize: 10,
      fontFamily: 'Roboto');

  static TextStyle whiteLower =
      TextStyle(color: SoloColor.white, fontSize: SoloSize.lower);

  static TextStyle whiteW900extraLarge = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w900,
    fontSize: SoloSize.extraLarge,
    letterSpacing: 2,
  );

  static TextStyle whiteW400medium = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w400,
    fontSize: SoloSize.medium,
  );
  static TextStyle blackW600medium = TextStyle(
    color: SoloColor.black,
    fontWeight: FontWeight.w600,
    fontSize: SoloSize.medium,
  );

  static TextStyle lightGrey200 = TextStyle(color: SoloColor.lightGrey200);
  static TextStyle white11 = TextStyle(
      fontFamily: 'Montserrat', fontSize: 11.0, color: SoloColor.white);

  static TextStyle white = TextStyle(color: SoloColor.white);

  static TextStyle lightGrey200W600Medium = TextStyle(
      fontSize: Constants.FONT_MEDIUM,
      color: SoloColor.lightGrey200,
      fontWeight: FontWeight.w600);

  static TextStyle electricPinkNormalMedium = TextStyle(
      fontSize: Constants.FONT_MEDIUM,
      color: SoloColor.electricPink,
      fontWeight: FontWeight.normal);

  static TextStyle electricPink = TextStyle(color: SoloColor.electricPink);

  static TextStyle montserrat20 =
      TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  static TextStyle grayBold =
      TextStyle(color: SoloColor.spanishGray, fontSize: SoloSize.low);

  static TextStyle blackBold = TextStyle(fontWeight: FontWeight.bold);
  static TextStyle blackW700TopXs = TextStyle(
    color: SoloColor.black,
    fontWeight: FontWeight.w700,
    fontSize: SoloSize.topXs,
  );
  static TextStyle blackW500Medium = TextStyle(
    color: SoloColor.black,
    fontWeight: FontWeight.w400,
    fontSize: SoloSize.medium,
  );
  static TextStyle blackBold22 = TextStyle(
      color: SoloColor.black, fontWeight: FontWeight.bold, fontSize: 22);

  static TextStyle spanishGrayNormalFontTop = TextStyle(
      fontSize: Constants.FONT_TOP,
      fontWeight: FontWeight.normal,
      color: SoloColor.spanishGray);

  static TextStyle batteryChargedBlueBoldF0ntTop = TextStyle(
      color: SoloColor.batteryChargedBlue,
      fontWeight: FontWeight.bold,
      fontSize: Constants.FONT_TOP);

  static TextStyle blackW500FontTop = TextStyle(
      color: SoloColor.black,
      fontSize: Constants.FONT_TOP,
      fontWeight: FontWeight.w500);

  static TextStyle spanishGrayW400FontMedium = TextStyle(
      color: SoloColor.spanishGray,
      fontSize: Constants.FONT_MEDIUM,
      fontWeight: FontWeight.w400);

  static TextStyle boldBoldF0ntTopBlack = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: Constants.FONT_MAXIMUM,
      color: SoloColor.black);

  static TextStyle titleNevBlack = TextStyle(
      color: SoloColor.black.withOpacity(0.3),
      fontWeight: FontWeight.w500,
      fontSize: 12);

  static TextStyle pinkNormalMediumRob = TextStyle(
      color: SoloColor.pink,
      fontWeight: FontWeight.w700,
      fontSize: Constants.FONT_LOW,
      fontFamily: 'Roboto');

  static TextStyle pinkNormalMediumXsRob = TextStyle(
      color: SoloColor.pink,
      fontWeight: FontWeight.w700,
      fontSize: SoloSize.medium_xs,
      fontFamily: 'Roboto');
  static TextStyle blueNormalMediumRob = TextStyle(
      color: SoloColor.blue,
      fontWeight: FontWeight.w700,
      fontSize: Constants.FONT_LOW,
      fontFamily: 'Roboto');

  static TextStyle blueNormalMediumXsRob = TextStyle(
      color: SoloColor.blue,
      fontWeight: FontWeight.w700,
      fontSize: SoloSize.medium_xs,
      fontFamily: 'Roboto');

  static TextStyle spanishGrayNormalMediumRob = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: Constants.FONT_LOW,
      color: SoloColor.spanishGray,
      fontFamily: 'Roboto');

  static TextStyle spanishGrayNormalMediumXsRob = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: SoloSize.medium_xs,
      color: SoloColor.spanishGray,
      fontFamily: 'Roboto');

  static TextStyle pinkBoldMediumRob = TextStyle(
      color: SoloColor.pink,
      fontWeight: FontWeight.bold,
      fontSize: Constants.FONT_MEDIUM,
      fontFamily: 'Roboto');

  static TextStyle blackNormalMediumRob = TextStyle(
      color: SoloColor.black,
      fontWeight: FontWeight.normal,
      fontSize: Constants.FONT_MEDIUM,
      fontFamily: 'Roboto');

  static TextStyle blackW500FontAppTitle = TextStyle(
      fontWeight: FontWeight.w500,
      color: SoloColor.black,
      fontSize: Constants.FONT_APP_TITLE);

  static TextStyle spanishGrayBoldFontMedium = TextStyle(
      fontWeight: FontWeight.bold,
      color: SoloColor.spanishGray,
      fontSize: Constants.FONT_MEDIUM);

  static TextStyle spanishGrayNormalFontMedium = TextStyle(
      fontWeight: FontWeight.normal,
      color: SoloColor.spanishGray,
      fontSize: Constants.FONT_MEDIUM);

  static TextStyle spanishGrayW500FontLow = TextStyle(
      fontWeight: FontWeight.w500,
      color: SoloColor.spanishGray,
      fontSize: Constants.FONT_LOW);


  static TextStyle blue = TextStyle(color: SoloColor.blue);

  static TextStyle spanishGrayFontMedium = TextStyle(
    color: SoloColor.spanishGray,
    fontSize: Constants.FONT_MEDIUM,
  );
}
