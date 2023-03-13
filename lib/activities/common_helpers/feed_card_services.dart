import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/helpers/common_helper.dart';

import '../../helpers/space.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/text_styles.dart';

class FeedCardService extends StatefulWidget {
  final String userProfile;
  final String userName;
  final String userLocation;
  final Function() userDetailsOnTap;
  final Function() moreTap;
  final Function() feedTap;
  final String imageUrl;
  final String likeCount;
  final String likeImage;
  final Function() likeOnTap;
  final Function()? likeTextTap;
  final String commentCount;
  final Function() commentOnTap;
  final String carnivalsText;

  final int indexForSearch;
  final String countDown;
  final CarouselController controller;
  FeedCardService(
      {Key? key,
      required this.moreTap,
      required this.userName,
      required this.userLocation,
      required this.userProfile,
      required this.userDetailsOnTap,
      required this.feedTap,
      required this.imageUrl,
      required this.likeCount,
      required this.likeImage,
      required this.likeOnTap,
      required this.commentCount,
      required this.commentOnTap,
      required this.countDown,
      required this.controller,
      required this.indexForSearch,
      required this.carnivalsText,
      this.likeTextTap})
      : super(key: key);

  @override
  State<FeedCardService> createState() => _FeedCardServiceState();
}

class _FeedCardServiceState extends State<FeedCardService> {
  late CommonHelper _commonHelper;
  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return Padding(
        padding: EdgeInsets.only(
          left: _commonHelper.screenWidth * 0.035,
          right: _commonHelper.screenWidth * 0.035,
          bottom: _commonHelper.screenHeight * 0.01,
          top: _commonHelper.screenHeight * 0.01,
        ),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: SoloColor.spanishGray.withOpacity(0.6),
              blurRadius: 3,
              spreadRadius: 0.5,
            ),
          ], color: SoloColor.white, borderRadius: BorderRadius.circular(20)),
          width: _commonHelper.screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        widget.carnivalsText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: SoloStyle.blackW700TopXs,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: widget.moreTap,
                        child: SvgPicture.asset(
                          IconsHelper.drop_arrow,
                          height: _commonHelper.screenHeight * 0.01,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: widget.feedTap,
                child: Container(
                  height: _commonHelper.screenHeight * 0.3,
                  width: _commonHelper.screenWidth,
                  child: ClipRRect(
                    child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder()),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  userDetail(
                      userDetailsOnTap: widget.userDetailsOnTap,
                      countDown: widget.countDown,
                      userName: widget.userName,
                      userProfile: widget.userProfile),
                  Row(
                    children: [
                      likeComment(
                        text: widget.likeCount,
                        onTap: widget.likeOnTap,
                        icon: widget.likeImage,
                        textTap: widget.likeTextTap,
                      ),
                      space(width: 3),
                      likeComment(
                          text: widget.commentCount,
                          onTap: widget.commentOnTap,
                          icon: IconsHelper.message),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget likeComment({
    required String text,
    required String icon,
    Function()? textTap,
    required Function() onTap,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: onTap,
          child: SvgPicture.asset(
            icon,
            height: _commonHelper.screenHeight * 0.025,
          ),
        ),
        space(width: 5),
        text.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 5),
                child: InkWell(
                  onTap: textTap,
                  child: SizedBox(
                    width: 20,
                    child: Center(
                      child: Text(
                        text,
                        style: SoloStyle.darkBlackW800SmallMax,
                      ),
                    ),
                  ),
                ),
              )
      ],
    );
  }

  Widget userDetail({
    required String userProfile,
    required String userName,
    required String countDown,
    required Function() userDetailsOnTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: userDetailsOnTap,
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        imageUrl: userProfile,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder()),
                  ),
                ),
                space(width: _commonHelper.screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: _commonHelper.screenWidth * 0.4,
                      child: Text(userName,
                          overflow: TextOverflow.ellipsis,
                          style: SoloStyle.black54W500SmallMax),
                    ),
                    Text(
                      countDown,
                      style: SoloStyle.lightGrey200W600MediumXs,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
