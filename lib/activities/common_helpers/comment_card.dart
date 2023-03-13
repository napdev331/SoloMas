import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../helpers/common_helper.dart';
import '../../helpers/space.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/read_more_text.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';

class CommentCard extends StatefulWidget {
  final String userProfile;
  final String username;
  final void Function()? moreOnTap;
  final String content;
  final String likeImage;
  final void Function() likeOnTap;
  final String likeCount;
  final void Function() likeTextOnTap;
  final void Function() commentOnTap;
  final String commentCount;
  final void Function() commentTextOnTap;
  final String countDown;
  final bool? moreOnTapIcon;
  final void Function()? userProfileTap;

  const CommentCard(
      {Key? key,
      required this.userProfile,
      required this.username,
      this.moreOnTap,
      required this.content,
      required this.likeImage,
      required this.likeOnTap,
      required this.likeCount,
      required this.likeTextOnTap,
      required this.commentTextOnTap,
      required this.commentCount,
      required this.commentOnTap,
      required this.countDown,
      this.moreOnTapIcon = false,
      this.userProfileTap})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late CommonHelper _commonHelper;

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.userProfileTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(55.0)),
                  boxShadow: [
                    BoxShadow(blurRadius: 1.5, color: SoloColor.taupeGray),
                  ],
                ),
                height: _commonHelper.screenHeight * .06,
                width: _commonHelper.screenHeight * .06,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: _commonHelper.screenHeight * .022,
                          width: _commonHelper.screenHeight * .022,
                          imageUrl: widget.userProfile,
                          placeholder: (context, url) => imagePlaceHolder(),
                          errorWidget: (context, url, error) =>
                              imagePlaceHolder())),
                ),
              ),
            ),
            space(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.username,
                          style: SoloStyle.graniteGrayW500TopXs),
                      widget.moreOnTapIcon == true
                          ? InkWell(
                              onTap: widget.moreOnTap,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 2),
                                child: Image.asset(
                                  IconsHelper.comment_doted,
                                  width: 16,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  space(height: 4),
                  ReadMoreText(
                    widget.content.toString(),
                    trimLength: 70,
                    style: SoloStyle.blackW500Medium,
                    colorClickableText: SoloColor.blueAssent,
                    trimMode: TrimMode.Length,
                    trimCollapsedText: StringHelper.readMore,
                    trimExpandedText: StringHelper.readLess,
                  ),
                  space(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          likeComment(
                              text: widget.likeCount,
                              textStyle: SoloStyle.blueAssentW500Medium,
                              icon: widget.likeImage,
                              color: SoloColor.blueAssent,
                              showLikesOnTap: widget.likeTextOnTap,
                              onTap: widget.likeOnTap),
                          space(width: 8),
                          likeComment(
                              text: widget.commentCount,
                              icon: IconsHelper.message,
                              showLikesOnTap: widget.commentTextOnTap,
                              onTap: widget.commentOnTap)
                        ],
                      ),
                      Text(
                        widget.countDown,
                        style: SoloStyle.lightGrey200W700low,
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 1),
        //   child: Divider(
        //       thickness: 0.8,
        //       color: SoloColor.spanishLightGrey.withOpacity(0.3)),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Divider(
              color: SoloColor.silverSand.withOpacity(0.2), thickness: 1),
        ),
      ],
    );
  }

  Widget likeComment({
    required String text,
    required String icon,
    Function()? showLikesOnTap,
    Color? color,
    TextStyle? textStyle,
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
              color: color ?? SoloColor.black.withOpacity(0.6),
              width: 16,
            ),
          ),
          space(width: 5),
          InkWell(
            onTap: showLikesOnTap ?? () {},
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Text(
                text,
                style: textStyle ?? SoloStyle.graniteGrayW500Medium,
              ),
            ),
          )
        ],
      ),
    );
  }
}
