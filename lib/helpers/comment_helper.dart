import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../activities/common_helpers/read_more_text.dart';
import '../model/blog_comment_blog.dart';
import '../resources_helper/colors.dart';
import '../resources_helper/common_widget.dart';
import '../resources_helper/dimens.dart';
import '../resources_helper/images.dart';
import '../resources_helper/strings.dart';
import 'common_helper.dart';
import 'constants.dart';

class CommentHelper {
  static Widget sendCommentField(BuildContext context,
      {required void Function()? onSend,
      required TextEditingController controller,
      bool autofocus = false,
      FocusNode? focusNode,
      String? id = "",
      String? hintText,
      Widget? prefixIcon}) {
    ScrollController? _scrollController;
    CommonHelper? _commonHelper;
    _commonHelper = CommonHelper(context);

    void _animateScrolling() {
      Timer(
          Duration(milliseconds: 500),
          () => _scrollController
              ?.jumpTo(_scrollController.position.maxScrollExtent));
    }

    var _sendCommentFocusNode = FocusNode();
    return Container(
      alignment: Alignment.bottomCenter,
      color: SoloColor.white,
      child: Row(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              color: SoloColor.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xffe8e8e8),
                  blurRadius: 10.0,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            width: _commonHelper.screenWidth * .78,
            padding: EdgeInsets.only(left: 15, top: 5),
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              autofocus: autofocus,
              minLines: 1,
              maxLines: 4,
              controller: controller,
              focusNode: focusNode ?? _sendCommentFocusNode,
              onTap: () {
                id = "";
                _animateScrolling();
              },
              cursorColor: SoloColor.blue,
              decoration: InputDecoration(
                prefixIcon: prefixIcon,
                border: InputBorder.none,
                hintText: hintText != null
                    ? hintText
                    : id!.isEmpty
                        ? 'Enter your comments'
                        : 'Write a Reply',
                hintStyle:
                    TextStyle(color: SoloColor.spanishGray, fontSize: 16),
                suffixIcon: IconButton(
                    icon: SvgPicture.asset(
                      IconsHelper.send_msg,
                      width: 25,
                    ),
                    onPressed: onSend),
                fillColor: SoloColor.white,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // start for userDetails code
  static Widget userDetails(BuildContext context, int index,
      {required bool idCheck,
      required String userName,
      void Function()? threeDotTap,
      required String content,
      void Function()? replyTap,
      required String commentTime,
      required int replyCount,
      required Widget Function(BuildContext, int) replyBuilder,
      required String profilePic}) {
    CommonHelper? _commonHelper;
    _commonHelper = CommonHelper(context);
    Widget profileImage(int index, String profilePic) {
      return GestureDetector(
        onTap: () {
          /*   if (_aList[index].userId == mineUserId) {
            _commonHelper.startActivity(ProfileTab(isFromHome: true));
          } else {
            _commonHelper.startActivity(
                UserProfileActivity(userId: _aList[index].userId));
          }*/
        },
        child: ClipOval(
            child: CachedNetworkImage(
                imageUrl: profilePic,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => imagePlaceHolder(),
                errorWidget: (context, url, error) => imagePlaceHolder())),
      );
    }

    return idCheck
        ? Container(
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin, top: DimensHelper.sidesMargin),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding:
                                EdgeInsets.only(right: DimensHelper.halfSides),
                            child: profileImage(index, profilePic),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(userName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: SoloColor.spanishGray,
                                            fontSize: Constants.FONT_MEDIUM)),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: GestureDetector(
                                        onTap: threeDotTap,
                                        child: Container(
                                          height: _commonHelper.screenHeight *
                                              0.025,
                                          width:
                                              _commonHelper.screenWidth * 0.050,
                                          child: Image.asset(
                                            IconsHelper.comment_doted,
                                            //width: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: DimensHelper.smallSides),
                                      child: Container(
                                        width:
                                            _commonHelper?.screenWidth * 0.80,
                                        child: ReadMoreText(
                                          content,
                                          trimLength: 170,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: SoloColor.black,
                                              fontSize: Constants.FONT_TOP),
                                          colorClickableText:
                                              SoloColor.spanishGray,
                                          trimMode: TrimMode.Length,
                                          trimCollapsedText:
                                              StringHelper.readMore,
                                          trimExpandedText:
                                              StringHelper.readLess,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                          onTap: replyTap,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: Text(
                                              "Reply",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: SoloColor.spanishGray,
                                                  fontSize: Constants.FONT_LOW),
                                            ),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Text(commentTime,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: SoloColor.spanishGray,
                                                fontSize: Constants.FONT_LOW)),
                                      ),

                                      // RichText(
                                      //     text: TextSpan(
                                      //   text:
                                      //       '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}',
                                      //   style: TextStyle(
                                      //       fontWeight: FontWeight.w500,
                                      //       color: SoloColor.spanishGray,
                                      //       fontSize: Constants.FONT_LOW),
                                      //   children: [
                                      //     TextSpan(
                                      //         text: 'Reply ',
                                      //         recognizer: TapGestureRecognizer()
                                      //           ..onTap = () {
                                      //             replyId = _aList?[index]
                                      //                 .blogCommentId;
                                      //
                                      //             FocusScope.of(context)
                                      //                 .requestFocus(
                                      //                     _sendCommentFocusNode);
                                      //           }),
                                      //   ],
                                      // ))
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: replyCount,
                                  itemBuilder: replyBuilder,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin, top: DimensHelper.sidesMargin),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding:
                                EdgeInsets.only(right: DimensHelper.halfSides),
                            child: profileImage(index, profilePic),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(userName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: SoloColor.spanishGray,
                                            fontSize: Constants.FONT_MEDIUM)),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: DimensHelper.smallSides),
                                      child: Container(
                                        width: _commonHelper.screenWidth * 0.80,
                                        child: ReadMoreText(
                                          content,
                                          trimLength: 170,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: SoloColor.black,
                                              fontSize: Constants.FONT_TOP),
                                          colorClickableText:
                                              SoloColor.spanishGray,
                                          trimMode: TrimMode.Length,
                                          trimCollapsedText:
                                              StringHelper.readMore,
                                          trimExpandedText:
                                              StringHelper.readLess,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                          onTap: replyTap,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: Text(
                                              "Reply",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: SoloColor.spanishGray,
                                                  fontSize: Constants.FONT_LOW),
                                            ),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Text(commentTime,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: SoloColor.spanishGray,
                                                fontSize: Constants.FONT_LOW)),
                                      ),

                                      // RichText(
                                      //     text: TextSpan(
                                      //   text:
                                      //       '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}',
                                      //   style: TextStyle(
                                      //       fontWeight: FontWeight.w500,
                                      //       color: SoloColor.spanishGray,
                                      //       fontSize: Constants.FONT_LOW),
                                      //   children: [
                                      //     TextSpan(
                                      //         text: 'Reply ',
                                      //         recognizer: TapGestureRecognizer()
                                      //           ..onTap = () {
                                      //             replyId = _aList?[index]
                                      //                 .blogCommentId;
                                      //
                                      //             FocusScope.of(context)
                                      //                 .requestFocus(
                                      //                     _sendCommentFocusNode);
                                      //           }),
                                      //   ],
                                      // ))
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    itemCount: replyCount,
                                    itemBuilder: replyBuilder)
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
              ],
            ),
          );
  }

  static Widget replyItem(BuildContext context,
      {required int listIndex,
      required ReplyData replyData,
      required int replyIndex,
      required void Function() viewAllTap,
      required bool viewAllReply,
      required String viewAllReplyLength,
      required bool viewAllReplyComment,
      required String replyProfileImage,
      required String replyUserName,
      required void Function() replyCommentThreeDotTap,
      required bool visibilityCommentThreeDot,
      required String replyCommentData,
      required String replyCommentTime}) {
    CommonHelper? _commonHelper;
    _commonHelper = CommonHelper(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: viewAllTap,
          child: Visibility(
            visible: viewAllReply,
            child: Padding(
              padding: EdgeInsets.only(top: DimensHelper.sidesMargin),
              child: Text('-------View all replies ($viewAllReplyLength)',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: SoloColor.spanishGray,
                      fontSize: Constants.FONT_LOW)),
            ),
          ),
        ),
        Visibility(
            visible: viewAllReplyComment,
            child: Container(
              padding: EdgeInsets.only(
                  top: DimensHelper.sidesMargin,
                  bottom: DimensHelper.halfSides),
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              /*_commonHelper.startActivity(UserProfileActivity(
                                    userId: replyData.userId));*/
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  right: DimensHelper.halfSides),
                              child: ClipOval(
                                  child: CachedNetworkImage(
                                      imageUrl: replyProfileImage,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          imagePlaceHolder(),
                                      errorWidget: (context, url, error) =>
                                          imagePlaceHolder())),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: _commonHelper.screenWidth * .55,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(replyUserName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: SoloColor.spanishGray,
                                              fontSize: Constants.FONT_MEDIUM)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 50),
                                        child: GestureDetector(
                                          onTap: replyCommentThreeDotTap,
                                          child: Visibility(
                                            visible: visibilityCommentThreeDot,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                height: _commonHelper
                                                        ?.screenHeight *
                                                    0.025,
                                                width:
                                                    _commonHelper?.screenWidth *
                                                        0.050,
                                                child: Image.asset(
                                                  IconsHelper.comment_doted,
                                                  //width: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: DimensHelper.smallSides),
                                    child: Container(
                                      width: _commonHelper?.screenWidth * 0.60,
                                      child: ReadMoreText(
                                        replyCommentData,
                                        trimLength: 170,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: SoloColor.black,
                                            fontSize: Constants.FONT_TOP),
                                        colorClickableText:
                                            SoloColor.spanishGray,
                                        trimMode: TrimMode.Length,
                                        trimCollapsedText:
                                            StringHelper.readMore,
                                        trimExpandedText: StringHelper.readLess,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: DimensHelper.smallSides,
                                            right: 50),
                                        child: Text(replyCommentTime,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: SoloColor.spanishGray,
                                                fontSize: Constants.FONT_LOW)),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ))
      ],
    );
  }
}
