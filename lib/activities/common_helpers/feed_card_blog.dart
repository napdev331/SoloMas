import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/helpers/common_helper.dart';

import '../../helpers/space.dart';
import '../../model/blog_list_model.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/read_more_text.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';

class FeedCardBlog extends StatefulWidget {
  final String userProfile;
  final String userName;
  final String userLocation;
  final Function() userDetailsOnTap;
  final Function() moreTap;
  final Function() feedTap;
  final List<BlogList> feedImage;
  final String likeCount;
  final String likeImage;
  final Function() likeOnTap;
  final String commentCount;
  final Function() commentOnTap;
  final Function()? likeTextTap;
  final String content;
  final int indexForSearch;
  final String countDown;
  final CarouselController controller;
  final GestureRecognizer? customReadMoreTap;
  FeedCardBlog({
    Key? key,
    required this.moreTap,
    required this.userName,
    required this.userLocation,
    required this.userProfile,
    required this.userDetailsOnTap,
    required this.feedTap,
    required this.feedImage,
    required this.likeCount,
    required this.likeImage,
    required this.likeOnTap,
    required this.commentCount,
    required this.commentOnTap,
    required this.countDown,
    required this.content,
    required this.controller,
    required this.indexForSearch,
    this.likeTextTap,
    this.customReadMoreTap,
  }) : super(key: key);

  @override
  State<FeedCardBlog> createState() => _FeedCardBlogState();
}

class _FeedCardBlogState extends State<FeedCardBlog> {
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
              userDetailsOnTap: widget.userDetailsOnTap,
              moreTap: widget.moreTap,
              userName: widget.userName),
          InkWell(
            onTap: widget.feedTap,
            child: Stack(
              children: [
                Container(
                  height: _commonHelper.screenHeight * 0.3,
                  width: _commonHelper.screenWidth,
                  child: ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: widget.feedImage[widget.indexForSearch].image
                          .toString(),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => imagePlaceHolder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    likeComment(
                        text: widget.likeCount,
                        onTap: widget.likeOnTap,
                        icon: widget.likeImage,
                        textOnTap: widget.likeTextTap),
                    space(width: 5),
                    likeComment(
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
            padding: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
            child: Container(
                width: _commonHelper.screenWidth,
                child: ReadMoreText(
                  widget.content,
                  trimLength: 130,
                  customOnTap: widget.customReadMoreTap,
                  style: SoloStyle.lightGrey200W500SmallMax,
                  colorClickableText: SoloColor.black,
                  trimMode: TrimMode.Length,
                  trimCollapsedText: StringHelper.readMore,
                  trimExpandedText: StringHelper.readLess,
                )),
          ),
        ]),
      ),
    );
  }

  Widget likeComment({
    required String text,
    required String icon,
    required Function() onTap,
    Function()? textOnTap,
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
        InkWell(
          onTap: onTap,
          child: Text(
            text,
            style: SoloStyle.darkBlackW800SmallMax,
          ),
        )
      ],
    );
  }

  Widget userDetail({
    required String userName,
    required Function() moreTap,
    required Function() userDetailsOnTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: userDetailsOnTap,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: _commonHelper.screenWidth * 0.70,
                      child: Text(userName,
                          overflow: TextOverflow.ellipsis,
                          style: SoloStyle.black54W500SmallMax),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: moreTap,
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
