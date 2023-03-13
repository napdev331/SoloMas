import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/helpers/space.dart';

import '../../helpers/common_helper.dart';
import '../../helpers/constants.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/dimens.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';

Widget listExplore(BuildContext context,
    {String? title,
    int? itemCount,
    bool isData = false,
    void Function()? onTap,
    Widget Function(BuildContext, int)? itemListBuilder,
    required String warningText}) {
  CommonHelper? _commonHelper;
  _commonHelper = CommonHelper(context);
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title!,
            style: SoloStyle.darkBlackW70020Rob,
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              width: 50,
              height: 25,
              child: Center(
                child: Text(
                  StringHelper.seeAll.toUpperCase(),
                  style: TextStyle(
                    shadows: [
                      Shadow(color: SoloColor.black, offset: Offset(0, -5))
                    ],
                    color: Colors.transparent,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                    decorationColor: SoloColor.pink,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Stack(
        children: [
          Container(
              height: _commonHelper.screenHeight * 0.20,
              // height: _commonHelper.screenHeight * 0.22,
              // height: _commonHelper.screenHeight * 0.25,
              child: isData
                  ? Center(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: itemCount,
                          itemBuilder: itemListBuilder ??
                              (BuildContext context, int index) {
                                return Container();
                              }),
                    )
                  : noCarnivalWarning(warningText)),
          // Align(
          //   child: ProgressBarIndicator(
          //       _commonHelper?.screenSize, _progressShow),
          //   alignment: FractionalOffset.center,
          // ),
        ],
      ),
    ],
  );
}

Widget noCarnivalWarning(String? warningText) {
  return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(DimensHelper.btnTopMargin),
      child: Text(warningText ?? "",
          style: TextStyle(
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.normal,
              color: SoloColor.spanishGray)));
}

Widget listCard(BuildContext context, int index,
    {required String countryTitle,
    String? countList,
    required String image,
    void Function()? onAllTap,
    EdgeInsetsGeometry? padding,
    bool isWidth = false,
    bool isHeight = false,
    bool isCount = false,
    double? bottomPositionSize,
    double? boxWidth,
    double? boxShadowWidth,
    void Function()? onReviewTap,
    void Function()? onShareTap,
    Gradient? gradient,
    String? title}) {
  CommonHelper? _commonHelper;
  _commonHelper = CommonHelper(context);
  return Padding(
    padding: padding ??
        EdgeInsets.only(
            right: _commonHelper.screenWidth * 0.025,
            // right: _commonHelper.screenWidth * 0.03,
            top: _commonHelper.screenHeight * 0.01),
    child: GestureDetector(
      onTap: onAllTap,
      child: Stack(children: [
        Container(
            width: isWidth
                ? _commonHelper.screenWidth * 0.9
                : boxWidth ?? _commonHelper.screenWidth * 0.30,
            // : boxWidth ?? _commonHelper.screenWidth * 0.33,
            // : boxWidth ?? _commonHelper.screenWidth * 0.35,
            // : boxWidth ?? _commonHelper.screenWidth * 0.4,
            height: isHeight
                ? _commonHelper.screenHeight * 0.24
                : _commonHelper.screenHeight * 0.18,
            // : _commonHelper.screenHeight * 0.22,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: SoloColor.lightGrey200.withOpacity(0.2),
                  blurRadius: 1,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    placeholder: (context, url) => imagePlaceHolder(),
                    errorWidget: (context, url, error) => imagePlaceHolder(),
                    imageUrl: image,
                  )),
            )),
        Container(
            height: isHeight
                ? _commonHelper.screenHeight * 0.24
                : _commonHelper.screenHeight * 0.18,
            width: isWidth
                ? _commonHelper.screenWidth * 0.5
                : boxWidth ?? _commonHelper.screenWidth * 0.30,
            // : boxWidth ?? _commonHelper.screenWidth * 0.33,
            // : boxShadowWidth ?? _commonHelper.screenWidth * 0.35,
            // : boxShadowWidth ?? _commonHelper.screenWidth * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              gradient: gradient ??
                  LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.transparent,
                      SoloColor.black.withOpacity(0.5),
                    ],
                  ),
            )),
        title != null
            ? Positioned(
                left: _commonHelper.screenWidth * 0.030,
                right: _commonHelper.screenWidth * 0.015,
                top: _commonHelper.screenWidth * 0.030,
                child: Container(
                  height: 26,
                  width: _commonHelper.screenHeight * 0.20,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: SoloColor.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11),
                  ),
                ),
              )
            : SizedBox.shrink(),
        isCount
            ? Positioned(
                right: _commonHelper.screenWidth * 0.02,
                // right: _commonHelper.screenWidth * 0.04,
                top: _commonHelper.screenHeight * 0.01,
                // top: _commonHelper.screenHeight * 0.015,
                child: Container(
                  height: _commonHelper.screenWidth * 0.08,
                  width: _commonHelper.screenWidth * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.transparent.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    countList ?? "",
                    style: TextStyle(color: SoloColor.white),
                  )),
                ),
              )
            : SizedBox.shrink(),
        title != null
            ? Positioned(
                bottom: _commonHelper.screenWidth * 0.03,
                left: _commonHelper.screenWidth * 0.03,
                right: _commonHelper.screenWidth * 0.03,
                child: SizedBox(
                  width: isWidth
                      ? _commonHelper.screenWidth * 0.6
                      : boxShadowWidth ?? _commonHelper.screenWidth * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: _commonHelper.screenWidth * 0.20,
                        decoration: BoxDecoration(
                          color: SoloColor.lightGrey200.withOpacity(0.6),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            child: Text(
                              countryTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: SoloStyle.smokeWhiteW70010Rob,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onReviewTap,
                            child: SvgPicture.asset(IconsHelper.review,
                                width:
                                    CommonHelper(context).screenWidth * 0.07),
                          ),
                          space(height: 5),
                          InkWell(
                            onTap: onShareTap,
                            child: SvgPicture.asset(IconsHelper.shareRound,
                                width:
                                    CommonHelper(context).screenWidth * 0.07),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Positioned(
                bottom: isWidth
                    ? _commonHelper.screenWidth * 0.015
                    // ? _commonHelper.screenWidth * 0.025
                    : bottomPositionSize ?? _commonHelper.screenWidth * 0.035,
                // : bottomPositionSize ?? _commonHelper.screenWidth * 0.02,
                // : bottomPositionSize ?? _commonHelper.screenWidth * 0.04,
                // : bottomPositionSize ?? _commonHelper.screenWidth * 0.06,
                left: isWidth
                    ? _commonHelper.screenWidth * 0.025
                    : _commonHelper.screenWidth * 0.02,
                right: isWidth
                    ? _commonHelper.screenWidth * 0.025
                    : _commonHelper.screenWidth * 0.02,
                // left: _commonHelper.screenWidth * 0.03,
                child: Container(
                  // // width: _commonHelper.screenWidth * 0.25,
                  // // width: _commonHelper.screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: SoloColor.lightGrey200.withOpacity(0.6),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: _commonHelper.screenWidth * 0.03,
                          vertical: _commonHelper.screenHeight * 0.008),
                      child: Text(
                        countryTitle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: SoloStyle.smokeWhiteW70010Rob,
                      ),
                    ),
                  ),
                ),
              ),
      ]),
    ),
  );
}
