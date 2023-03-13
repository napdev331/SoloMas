import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/helpers/common_helper.dart';

import '../../helpers/space.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/dimens.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/text_styles.dart';

class FeedCardEvent extends StatefulWidget {
  final String? userProfile;
  final String userName;
  final String userLocation;
  final Function()? userDetailsOnTap;
  final Function()? moreTap;
  final Function()? feedTap;
  final String imagePath;
  final String? likeCount;
  final String? likeImage;
  final Function()? likeOnTap;
  final String? commentCount;
  final Function()? commentOnTap;
  final String carnivalsText;
  final String content;
  final EdgeInsetsGeometry? padding;
  final String countDown;
  final String? locationName;
  final String? description;
  final String? number;

  final String? date;
  final CarouselController carouselController;
  FeedCardEvent(
      {Key? key,
      this.moreTap,
      required this.userName,
      required this.userLocation,
      this.userProfile,
      this.userDetailsOnTap,
      this.feedTap,
      required this.imagePath,
      this.likeCount,
      this.likeImage,
      this.likeOnTap,
      this.commentCount,
      this.commentOnTap,
      required this.countDown,
      required this.content,
      required this.carouselController,
      required this.carnivalsText,
      this.padding,
      this.locationName,
      this.description,
      this.date,
      this.number})
      : super(key: key);

  @override
  State<FeedCardEvent> createState() => _FeedCardEventState();
}

class _FeedCardEventState extends State<FeedCardEvent> {
  late CommonHelper _commonHelper;
  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    print("Image ");
    print(widget.imagePath);

    return Padding(
        padding: widget.padding ??
            EdgeInsets.only(
              left: _commonHelper.screenWidth * 0.035,
              right: _commonHelper.screenWidth * 0.035,
              top: _commonHelper.screenHeight * 0.02,
              bottom: _commonHelper.screenHeight * 0.02,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 250,
                          child: Text(
                            widget.carnivalsText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SoloStyle.black54W500SmallMax,
                          ),
                        ),
                        if (widget.locationName != null)
                          SizedBox(
                            width: 250,
                            child: Text(
                              widget.locationName ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: SoloStyle.lightGrey200W600MediumXs,
                            ),
                          )
                      ],
                    ),
                  ),
                  if (widget.moreTap != null)
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
              InkWell(
                onTap: widget.feedTap,
                child: Column(
                  children: [
                    Container(
                      height: _commonHelper.screenHeight * 0.35,
                      width: _commonHelper.screenWidth,
                      child: ClipRRect(
                        child: CachedNetworkImage(
                            imageUrl: widget.imagePath,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => imagePlaceHolder(),
                            errorWidget: (context, url, error) =>
                                imagePlaceHolder()),
                      ),
                    ),
                    if (widget.description != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 10, left: 15, top: 10),
                          child: Text(
                            widget.description.toString(),
                            style: SoloStyle.lightGrey200W500SmallMax,
                          ),
                        ),
                      ),
                    if (widget.date != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            Image.asset(
                              IconsHelper.ic_calender,
                              width: _commonHelper.screenWidth * 0.05,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: DimensHelper.mediumSides,
                                  right: DimensHelper.mediumSides),
                              child: Text(
                                widget.date ?? "",
                                style: SoloStyle.darkBlackW70015Rob,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.userProfile != null)
                      Row(
                        children: [
                          Row(
                            children: [
                              userDetail(
                                  userDetailsOnTap:
                                      widget.userDetailsOnTap ?? () {},
                                  countDown: widget.countDown,
                                  userName: widget.userName,
                                  number: widget.number,
                                  userProfile: widget.userProfile ?? ""),
                            ],
                          ),
                          Row(
                            children: [
                              if (widget.likeCount != null)
                                likeComment(
                                    text: widget.likeCount ?? "",
                                    onTap: widget.likeOnTap ?? () {},
                                    icon: widget.likeImage ?? ""),
                              space(width: 5),
                              if (widget.commentCount != null)
                                likeComment(
                                    text: widget.commentCount ?? "",
                                    onTap: widget.commentOnTap ?? () {},
                                    icon: IconsHelper.message),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget likeComment({
    required String text,
    required String icon,
    required Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            child: SvgPicture.asset(
              icon,
              height: _commonHelper.screenHeight * 0.025,
            ),
          ),
          space(width: 5),
          Text(
            text,
            style: SoloStyle.darkBlackW800SmallMax,
          )
        ],
      ),
    );
  }

  Widget userDetail({
    required String userProfile,
    required String userName,
    required String countDown,
    String? number,
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
                userProfile.isEmpty
                    ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: AssetImage(
                                IconsHelper.profile_icon,
                              ),
                              fit: BoxFit.fill,
                            )),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(
                                userProfile,
                              ),
                              fit: BoxFit.fill,
                            )),
                      ),
                space(width: _commonHelper.screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _commonHelper.screenWidth * 0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: _commonHelper.screenWidth * 0.35,
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
                    ),
                    if (number != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          number,
                          style: SoloStyle.lightGrey200W600MediumXs,
                        ),
                      ),
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
