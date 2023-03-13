import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/common_helpers/read_more_text.dart';
import 'package:solomas/helpers/common_helper.dart';

import '../../helpers/space.dart';
import '../../model/public_feeds_model.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';

class FeedCard extends StatefulWidget {
  final String userProfile;
  final String userName;
  final String userLocation;
  final Function() userDetailsOnTap;
  final Function() userprofileOnTap;
  final Function() moreTap;
  final Function()? feedImageZoomOnTap;
  final Function()? feedTap;
  final List<PublicFeedList>? feedImage;
  final String likeCount;
  final String likeImage;
  final Function() likeOnTap;
  final Function() likeTextOnTap;
  final String commentCount;
  final Function() commentOnTap;

  final Function() commentTextOnTap;
  final bool reverseContent;
  final String content;
  final int indexForSearch;

  final String countDown;
  final CarouselController? controller;
  FeedCard(
      {Key? key,
      required this.moreTap,
      required this.userName,
      required this.userLocation,
      required this.userProfile,
      this.feedImageZoomOnTap,
      required this.userDetailsOnTap,
      this.feedTap,
      required this.userprofileOnTap,
      this.feedImage,
      this.reverseContent = false,
      required this.likeCount,
      required this.likeTextOnTap,
      required this.likeImage,
      required this.likeOnTap,
      required this.commentCount,
      required this.commentTextOnTap,
      required this.commentOnTap,
      required this.countDown,
      required this.content,
      this.controller,
      required this.indexForSearch})
      : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late CommonHelper _commonHelper;

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    print("Image ");
    print(widget.feedImage);

    return Padding(
      padding: EdgeInsets.only(
        left: _commonHelper.screenWidth * 0.035,
        right: _commonHelper.screenWidth * 0.035,
        top: _commonHelper.screenHeight * 0.031,
      ),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: SoloColor.spanishGray.withOpacity(0.4),
            blurRadius: 2.5,
            spreadRadius: 0.7,
          ),
        ], color: SoloColor.white, borderRadius: BorderRadius.circular(20)),
        width: _commonHelper.screenWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          userDetail(
              userDetailsOnTap: widget.userDetailsOnTap,
              moreTap: widget.moreTap,
              userLocation: widget.userLocation,
              userName: widget.userName,
              userProfile: widget.userProfile,
              userProfileOnTap: widget.userprofileOnTap),
          InkWell(
            onTap: widget.feedTap ?? () {},
            child: widget.feedImage != null
                ? Stack(
                    children: [
                      widget.feedImage![widget.indexForSearch].image!.length > 1
                          ? CarouselSlider.builder(
                              itemCount: widget
                                  .feedImage![widget.indexForSearch]
                                  .image!
                                  .length,
                              carouselController: widget.controller,
                              options: CarouselOptions(
                                autoPlay: false,
                                height: _commonHelper.screenHeight * 0.3,
                                viewportFraction: 1.0,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    widget.feedImage![widget.indexForSearch]
                                        .sliderPosition = index;
                                  });
                                },
                              ),
                              itemBuilder: (BuildContext context, int index,
                                  int realIndex) {
                                return Stack(
                                  children: [
                                    Container(
                                      height: _commonHelper.screenHeight * 0.3,
                                      width: _commonHelper.screenWidth,
                                      child: ClipRRect(
                                        child: CachedNetworkImage(
                                          imageUrl: widget
                                              .feedImage![widget.indexForSearch]
                                              .image![index],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              imagePlaceHolder(),
                                          errorWidget: (context, url, error) =>
                                              imagePlaceHolder(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: _commonHelper.screenHeight * 0.3,
                                      width: _commonHelper.screenWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                                // boxShadow: [
                                                //   BoxShadow(blurRadius: 3.0),
                                                // ],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: InkWell(
                                              onTap: widget.feedImageZoomOnTap,
                                              child: SvgPicture.asset(
                                                IconsHelper.imgZoom,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            // child: Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       right: 4.0, top: 220),
                                            //   child: Icon(
                                            //     Icons.zoom_in_map_outlined,
                                            //   ),
                                            // ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : Stack(
                              children: [
                                Container(
                                  height: _commonHelper.screenHeight * 0.3,
                                  width: _commonHelper.screenWidth,
                                  child: ClipRRect(
                                    child: CachedNetworkImage(
                                      imageUrl: widget
                                          .feedImage![widget.indexForSearch]
                                          .image![0],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          imagePlaceHolder(),
                                      errorWidget: (context, url, error) =>
                                          imagePlaceHolder(),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: _commonHelper.screenHeight * 0.3,
                                  width: _commonHelper.screenWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                            // boxShadow: [
                                            //   BoxShadow(blurRadius: 3.0),
                                            // ],
                                            borderRadius:
                                                BorderRadius.circular(10)),

                                        child: InkWell(
                                          onTap: widget.feedImageZoomOnTap,
                                          child: SvgPicture.asset(
                                            IconsHelper.imgZoom,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        // child: Padding(
                                        //   padding: const EdgeInsets.only(
                                        //       right: 4.0, top: 220),
                                        //   child: Icon(
                                        //     Icons.zoom_in_map_outlined,
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Visibility(
                          visible: widget.feedImage![widget.indexForSearch]
                                  .image!.length >
                              1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget
                                .feedImage![widget.indexForSearch].image!
                                .asMap()
                                .entries
                                .map((entry) {
                              return GestureDetector(
                                onTap: () =>
                                    widget.controller?.animateToPage(entry.key),
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget
                                                  .feedImage![
                                                      widget.indexForSearch]
                                                  .sliderPosition ==
                                              entry.key
                                          ? Colors.black
                                          : Colors.grey),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
          widget.reverseContent
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 10, left: 10, bottom: 15, top: 5),
                      child: Container(
                          width: _commonHelper.screenWidth,
                          child: ReadMoreText(
                            widget.content /*StringHelper.dummyHomeText*/,
                            trimLength: 140,
                            style: SoloStyle.lightGrey200W500SmallMax,
                            colorClickableText: SoloColor.black,
                            trimMode: TrimMode.Length,
                            trimCollapsedText: StringHelper.readMore,
                            trimExpandedText: StringHelper.readLess,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              likeComment(
                                  text: widget.likeCount,
                                  onTap: widget.likeOnTap,
                                  textOnTap: widget.likeTextOnTap,
                                  icon: widget.likeImage),
                              space(width: 3),
                              likeComment(
                                  text: widget.commentCount,
                                  onTap: widget.commentOnTap,
                                  textOnTap: widget.commentTextOnTap,
                                  icon: IconsHelper.message),
                            ],
                          ),
                          Text(
                            widget.countDown,
                            style: SoloStyle.lightGrey200W700low,
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              likeComment(
                                  textOnTap: widget.likeTextOnTap,
                                  text: widget.likeCount,
                                  onTap: widget.likeOnTap,
                                  icon: widget.likeImage),
                              space(width: 3),
                              likeComment(
                                  textOnTap: widget.commentTextOnTap,
                                  text: widget.commentCount,
                                  onTap: widget.commentOnTap,
                                  icon: IconsHelper.message),
                            ],
                          ),
                          Text(
                            widget.countDown,
                            style: SoloStyle.lightGrey200W700low,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 10, left: 10, bottom: 15, top: 5),
                      child: Container(
                          width: _commonHelper.screenWidth,
                          child: ReadMoreText(
                            widget.content /*StringHelper.dummyHomeText*/,
                            trimLength: 140,
                            style: SoloStyle.lightGrey200W500SmallMax,
                            colorClickableText: SoloColor.black,
                            trimMode: TrimMode.Length,
                            trimCollapsedText: StringHelper.readMore,
                            trimExpandedText: StringHelper.readLess,
                          )),
                    ),
                  ],
                )
        ]),
      ),
    );
  }

  Widget likeComment({
    required String text,
    required String icon,
    required Function() onTap,
    required Function() textOnTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              child: SvgPicture.asset(
                icon,
                color: SoloColor.jet.withOpacity(0.9),
                width: 18,
              ),
            ),
          ),
          space(width: 5),
          InkWell(
            onTap: textOnTap,
            child: Text(
              text,
              style: SoloStyle.darkBlackW800SmallMax,
            ),
          )
        ],
      ),
    );
  }

  Widget userDetail({
    required String userProfile,
    required String userName,
    required String userLocation,
    required Function() moreTap,
    required Function() userDetailsOnTap,
    required Function() userProfileOnTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                  onTap: userProfileOnTap,
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: userProfile,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder(),
                      ),
                    ),
                  )),
              space(width: _commonHelper.screenWidth * 0.03),
              InkWell(
                onTap: userDetailsOnTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: SoloStyle.black54W500SmallMax,
                    ),
                    // Text(
                    //   userLocation,
                    //   style: SoloStyle.lightGrey200W600MediumXs,
                    // )
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: moreTap,
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: SvgPicture.asset(
                IconsHelper.drop_arrow,
                height: _commonHelper.screenHeight * 0.01,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
