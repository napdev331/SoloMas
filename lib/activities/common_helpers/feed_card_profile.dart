import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/common_helpers/read_more_text.dart';
import 'package:solomas/helpers/common_helper.dart';

import '../../helpers/space.dart';
import '../../model/user_profile_model.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';

class FeedCardProfile extends StatefulWidget {
  final String userProfile;
  final String userName;
  final String userLocation;
  final Function()? userDetailsOnTap;
  final Function() moreTap;
  final Function()? feedTap;
  final List<Photo>? feedImage;
  final Function()? feedImageZoomOnTap;
  final String likeCount;
  final String likeImage;
  final Function() likeOnTap;
  final Function()? showLikesOnTap;
  final bool reverseContent;
  final String commentCount;
  final Function() commentOnTap;
  final String content;
  final int indexForSearch;
  final String? countDown;
  final CarouselController? controller;
  FeedCardProfile(
      {Key? key,
      required this.moreTap,
      required this.userName,
      required this.userLocation,
      required this.userProfile,
      this.userDetailsOnTap,
      this.feedImageZoomOnTap,
      this.feedTap,
      this.reverseContent = false,
      this.feedImage,
      required this.likeCount,
      required this.likeImage,
      required this.likeOnTap,
      this.showLikesOnTap,
      required this.commentCount,
      required this.commentOnTap,
      this.countDown,
      required this.content,
      this.controller,
      required this.indexForSearch})
      : super(key: key);

  @override
  State<FeedCardProfile> createState() => _FeedCardProfileState();
}

class _FeedCardProfileState extends State<FeedCardProfile> {
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
        top: _commonHelper.screenHeight * 0.02,
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          userDetail(
              userDetailsOnTap: widget.userDetailsOnTap ?? () {},
              moreTap: widget.moreTap,
              userLocation: widget.userLocation,
              userName: widget.userName,
              userProfile: widget.userProfile),
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
                                              onTap: widget
                                                      .feedImageZoomOnTap ??
                                                  () {

                                                  },
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
                      )
                    ],
                  )
                : SizedBox.shrink(),
          ),
          widget.reverseContent
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 10, left: 10, bottom: 15),
                      child: Container(
                          width: _commonHelper.screenWidth,
                          child: ReadMoreText(
                            widget.content ?? " ",
                            //StringHelper.dummyHomeText,
                            trimLines: 2,
                            style: SoloStyle.lightGrey200W500SmallMax,
                            colorClickableText: SoloColor.black,
                            trimMode: TrimMode.Line,
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
                                  textOnTap: widget.showLikesOnTap,
                                  icon: widget.likeImage),
                              space(width: 3),
                              likeComment(
                                  text: widget.commentCount,
                                  onTap: widget.commentOnTap,
                                  textOnTap: widget.commentOnTap,
                                  icon: IconsHelper.message),
                            ],
                          ),
                          Text(
                            widget.countDown ?? "",
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : Column(children: [
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
                                textOnTap: widget.showLikesOnTap,
                                icon: widget.likeImage),
                            space(width: 3),
                            likeComment(
                                text: widget.commentCount,
                                onTap: widget.commentOnTap,
                                textOnTap: widget.commentOnTap,
                                icon: IconsHelper.message),
                          ],
                        ),
                        Text(
                          widget.countDown ?? "",
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 10, left: 10, bottom: 15),
                    child: Container(
                        width: _commonHelper.screenWidth,
                        child: ReadMoreText(
                          widget.content ?? " ",
                          //StringHelper.dummyHomeText,
                          trimLines: 2,
                          style: SoloStyle.lightGrey200W500SmallMax,
                          colorClickableText: SoloColor.black,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: StringHelper.readMore,
                          trimExpandedText: StringHelper.readLess,
                        )),
                  )
                ]),
        ]),
      ),
    );
  }

  Widget likeComment({
    required String text,
    required String icon,
    Function()? textOnTap,
    required Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            child: SvgPicture.asset(
              icon,
              height: _commonHelper.screenHeight * 0.025,
            ),
          ),
          space(width: 8),
          InkWell(
            onTap: textOnTap ?? () {},
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Text(
                text,
                style: SoloStyle.darkBlackW800SmallMax,
              ),
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
                        width: 55,
                        height: 55,
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
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(
                                userProfile,
                              ),
                              fit: BoxFit.fill,
                            )),
                      ),
                space(width: _commonHelper.screenWidth * 0.04),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: SoloStyle.black54W500SmallMax,
                    ),
                    Text(
                      userLocation,
                      style: SoloStyle.lightGrey200W600MediumXs,
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: moreTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: SvgPicture.asset(
                  IconsHelper.drop_arrow,
                  height: _commonHelper.screenHeight * 0.01,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
