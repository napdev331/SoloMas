import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/public_feeds/feed_comment_list_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/feed_comment_list_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/comment_helper.dart';
import '../../helpers/space.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class PublicFeedCommentActivity extends StatefulWidget {
  final String? publicFeedId;

  final String? publicCommentId;

  final bool showKeyBoard;

  bool? scrollMessage;

  PublicFeedCommentActivity(
      {this.publicFeedId,
      this.showKeyBoard = false,
      this.scrollMessage,
      this.publicCommentId});

  // _PublicFeedCommentState createState() => _PublicFeedCommentState();

  @override
  State<StatefulWidget> createState() {
    return _PublicFeedCommentState();
  }
}

class _PublicFeedCommentState extends State<PublicFeedCommentActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  String? authToken, replyId = "", mineUserId;
  FeedCommentListBloc? _feedCommentListBloc;
  List<PublicCommentsList>? _aList;
  ScrollController? _scrollController;
  bool _progressShow = false, refreshData = false;
  var _sendCommentController = TextEditingController();
  var _sendCommentFocusNode = FocusNode();
  var pos = -1;
  bool isEditComment = false;
  ApiHelper? _apiHelper;
  String? editFeedId;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    Constants.isNavigated = false;
    _apiHelper = ApiHelper();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _scrollController = ScrollController();

    _feedCommentListBloc = FeedCommentListBloc();

    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) {
        replyId = "";
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _getFeedCommentList());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(context),
          ),
        ),
        body: _mainBody(),
      ),
    );
  }

  @override
  void dispose() {
    _feedCommentListBloc?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody() {
    return StreamBuilder(
        stream: _feedCommentListBloc?.commentFeedList,
        builder: (context, AsyncSnapshot<FeedCommentListModel> snapshot) {
          if (snapshot.hasData) {
            if (_aList == null || _aList!.isEmpty) {
              _aList = snapshot.data?.data?.publicCommentsList;
              if (widget.scrollMessage == true) {
                pos = _aList!.indexWhere((innerElement) =>
                    innerElement.publicCommentId == widget.publicCommentId);
                print(_aList!.indexWhere((innerElement) =>
                    innerElement.publicCommentId == widget.publicCommentId));

                if (pos == _aList!.length - 1) {
                  Future.delayed(Duration.zero, () => _animateScrolling());
                } else {
                  Future.delayed(
                      Duration.zero, () => _animateScrollingMessage(pos));
                }
              } else {
                Future.delayed(Duration.zero, () => _animateScrolling());
              }
            }
            return _commentListData(pos);
          } else if (snapshot.hasError) {
            return Container();
          }

          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        });
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.comments,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _showBottomSheetEditDel(
      String publicCommentId, int index, String comment) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text(StringHelper.edit,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);

          setState(() {
            isEditComment = true;

            editFeedId = publicCommentId;

            _sendCommentController.text = comment;

            _sendCommentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _sendCommentController.text.length));

            FocusScope.of(context).requestFocus(_sendCommentFocusNode);
          });
        },
      ),
      CupertinoActionSheetAction(
        child: Text(StringHelper.delete,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);

          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>
                  _showDeleteBottomSheet(publicCommentId, index));
        },
      ),
    ]);
  }

  Widget _showDeleteBottomSheet(String publicCommentId, int index) {
    return CupertinoActionSheet(
      title: Text(StringHelper.delComment,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.delCommentMsg,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);
            _deleteComment(publicCommentId, index);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.no,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget profileImage(int index) {
    return GestureDetector(
      onTap: () {
        if (_aList?[index].userId == mineUserId) {
          _commonHelper?.startActivity(ProfileTab(isFromHome: true));
        } else {
          _commonHelper?.startActivity(
              UserProfileActivity(userId: _aList![index].userId.toString()));
        }
      },
      child: ClipOval(
          child: CachedNetworkImage(
              imageUrl: _aList![index].userProfilePic.toString(),
              height: 40,
              width: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => imagePlaceHolder(),
              errorWidget: (context, url, error) => imagePlaceHolder())),
    );
  }

  Widget userDetails1(int index) {
    return _aList?[index].userId == mineUserId
        ? Container(
            color: SoloColor.blueWhite,
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                top: DimensHelper.sidesMargin,
                right: DimensHelper.tinySides,
                bottom: DimensHelper.sidesMargin),
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
                            child: profileImage(index),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _aList![index].userName.toString(),
                                    style: TextStyle(
                                        color: SoloColor.lightGrey200,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 35),
                                    child: GestureDetector(
                                      onTap: () {
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return _showBottomSheetEditDel(
                                                  _aList![index]
                                                      .publicCommentId
                                                      .toString(),
                                                  index,
                                                  _aList![index]
                                                      .comment
                                                      .toString());
                                            });
                                      },
                                      child: Container(
                                        height:
                                            _commonHelper?.screenHeight * 0.025,
                                        width:
                                            _commonHelper?.screenWidth * 0.050,
                                        child: Image.asset(
                                          IconsHelper.comment_doted,
                                          //width: 17,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              space(height: 3),
                              Text(
                                _aList![index].comment.toString(),
                              ),
                              space(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            replyId =
                                                _aList?[index].publicCommentId;

                                            FocusScope.of(context).requestFocus(
                                                _sendCommentFocusNode);
                                          },
                                          child: Text(StringHelper.reply))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                        style:
                                            SoloStyle.lightGrey200W600MediumXs,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Container(
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.start,
                        //           children: [
                        //             Container(
                        //               width: _commonHelper?.screenWidth - 100,
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.start,
                        //                 children: [
                        //                   Text(
                        //                       _aList![index]
                        //                           .userName
                        //                           .toString(),
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.w500,
                        //                           color: SoloColor.black,
                        //                           fontSize:
                        //                               Constants.FONT_TOP)),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         top: DimensHelper.smallSides),
                        //                     child: RichText(
                        //                         text: TextSpan(
                        //                       text:
                        //                           '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.w500,
                        //                           color: SoloColor.spanishGray,
                        //                           fontSize: Constants.FONT_LOW),
                        //                       children: [
                        //                         TextSpan(
                        //                             text: 'Reply ',
                        //                             recognizer:
                        //                                 TapGestureRecognizer()
                        //                                   ..onTap = () {
                        //                                     replyId = _aList?[
                        //                                             index]
                        //                                         .publicCommentId;
                        //
                        //                                     FocusScope.of(
                        //                                             context)
                        //                                         .requestFocus(
                        //                                             _sendCommentFocusNode);
                        //                                   }),
                        //                       ],
                        //                     )),
                        //                   ),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         top: DimensHelper.smallSides),
                        //                     child: Text(
                        //                         _aList![index]
                        //                             .comment
                        //                             .toString(),
                        //                         style: TextStyle(
                        //                             fontWeight:
                        //                                 FontWeight.normal,
                        //                             color:
                        //                                 SoloColor.spanishGray,
                        //                             fontSize:
                        //                                 Constants.FONT_MEDIUM)),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //             Spacer(),
                        //             GestureDetector(
                        //               onTap: () {
                        //                 showCupertinoModalPopup(
                        //                     context: context,
                        //                     builder: (BuildContext context) {
                        //                       return _showBottomSheetEditDel(
                        //                           _aList![index]
                        //                               .publicCommentId
                        //                               .toString(),
                        //                           index,
                        //                           _aList![index]
                        //                               .comment
                        //                               .toString());
                        //                     });
                        //               },
                        //               child: Align(
                        //                   alignment: Alignment.centerRight,
                        //                   child: Container(
                        //                     child: Icon(
                        //                       Icons.more_vert,
                        //                       color: SoloColor.spanishGray,
                        //                     ),
                        //                   )),
                        //             )
                        //           ],
                        //         ),
                        //         ListView.builder(
                        //           shrinkWrap: true,
                        //           physics: ScrollPhysics(),
                        //           itemCount: _aList?[index].replyData?.length,
                        //           itemBuilder: (context, replyDataIndex) {
                        //             return replyItem(
                        //                 index,
                        //                 _aList![index]
                        //                     .replyData![replyDataIndex],
                        //                 replyDataIndex);
                        //           },
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    )),
              ],
            ),
          )
        : Container(
            color: SoloColor.blueWhite,
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                top: DimensHelper.sidesMargin,
                right: DimensHelper.tinySides,
                bottom: DimensHelper.sidesMargin),
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
                            child: profileImage(index),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _aList![index].userName.toString(),
                                    style: TextStyle(
                                        color: SoloColor.lightGrey200,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {},
                                  //   child: Image.asset(
                                  //     IconsHelper.comment_doted,
                                  //     width: 15,
                                  //     height: 15,
                                  //   ),
                                  // )
                                ],
                              ),
                              space(height: 3),
                              Text(
                                _aList![index].comment.toString(),
                              ),
                              space(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            replyId =
                                                _aList?[index].publicCommentId;

                                            FocusScope.of(context).requestFocus(
                                                _sendCommentFocusNode);
                                          },
                                          child: Text(StringHelper.reply))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                        style:
                                            SoloStyle.lightGrey200W600MediumXs,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Container(
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.start,
                        //           children: [
                        //             Container(
                        //               width: _commonHelper?.screenWidth - 100,
                        //               child: Column(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.start,
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text(
                        //                       _aList![index]
                        //                           .userName
                        //                           .toString(),
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.w500,
                        //                           color: SoloColor.black,
                        //                           fontSize:
                        //                               Constants.FONT_TOP)),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         top: DimensHelper.smallSides),
                        //                     child: RichText(
                        //                         text: TextSpan(
                        //                       text:
                        //                           '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.w500,
                        //                           color: SoloColor.spanishGray,
                        //                           fontSize: Constants.FONT_LOW),
                        //                       children: [
                        //                         TextSpan(
                        //                             text: 'Reply ',
                        //                             recognizer:
                        //                                 TapGestureRecognizer()
                        //                                   ..onTap = () {
                        //                                     replyId = _aList?[
                        //                                             index]
                        //                                         .publicCommentId;
                        //
                        //                                     FocusScope.of(
                        //                                             context)
                        //                                         .requestFocus(
                        //                                             _sendCommentFocusNode);
                        //                                   }),
                        //                       ],
                        //                     )),
                        //                   ),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         top: DimensHelper.smallSides),
                        //                     child: Text(
                        //                         _aList![index]
                        //                             .comment
                        //                             .toString(),
                        //                         style: TextStyle(
                        //                             fontWeight:
                        //                                 FontWeight.normal,
                        //                             color:
                        //                                 SoloColor.spanishGray,
                        //                             fontSize:
                        //                                 Constants.FONT_MEDIUM)),
                        //                   ),
                        //                 ],
                        //               ),
                        //             )
                        //           ],
                        //         ),
                        //         ListView.builder(
                        //           shrinkWrap: true,
                        //           physics: ScrollPhysics(),
                        //           itemCount: _aList?[index].replyData?.length,
                        //           itemBuilder: (context, replyDataIndex) {
                        //             return replyItem(
                        //                 index,
                        //                 _aList![index]
                        //                     .replyData![replyDataIndex],
                        //                 replyDataIndex);
                        //           },
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    )),
              ],
            ),
          );
  }

  Widget userDetails(int index) {
    return _aList?[index].userId == mineUserId
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
                            child: profileImage(index),
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
                                    Text(_aList![index].userName.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: SoloColor.spanishGray,
                                            fontSize: Constants.FONT_MEDIUM)),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: GestureDetector(
                                        onTap: () {
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return _showBottomSheetEditDel(
                                                    _aList![index]
                                                        .publicCommentId
                                                        .toString(),
                                                    index,
                                                    _aList![index]
                                                        .comment
                                                        .toString());
                                              });
                                        },
                                        child: Container(
                                          height: _commonHelper?.screenHeight *
                                              0.025,
                                          width: _commonHelper?.screenWidth *
                                              0.050,
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
                                      child: Text(
                                          _aList![index].comment.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: SoloColor.black,
                                              fontSize: Constants.FONT_TOP)),
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
                                          onTap: () {
                                            replyId =
                                                _aList?[index].publicCommentId;

                                            FocusScope.of(context).requestFocus(
                                                _sendCommentFocusNode);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: Text(
                                              StringHelper.reply,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: SoloColor.spanishGray,
                                                  fontSize: Constants.FONT_LOW),
                                            ),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Text(
                                            "${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}",
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
                                  itemCount: _aList?[index].replyData?.length,
                                  itemBuilder: (context, replyDataIndex) {
                                    return CommentHelper.replyItem(context,
                                        listIndex: index,
                                        replyData: _aList![index]
                                            .replyData![replyDataIndex],
                                        replyIndex: replyDataIndex,
                                        viewAllTap: () {
                                          setState(() {
                                            _aList?[index].showReplies = true;
                                          });
                                        },
                                        viewAllReply: _aList?[index]
                                                    .replyData
                                                    ?.isNotEmpty ==
                                                true &&
                                            replyDataIndex == 0 &&
                                            _aList?[index].showReplies == false,
                                        viewAllReplyLength:
                                            '${_aList?[index].replyData?.length.toString()}',
                                        viewAllReplyComment:
                                            _aList![index].showReplies!,
                                        replyProfileImage: _aList![index]
                                            .replyData![replyDataIndex]
                                            .userProfilePic
                                            .toString(),
                                        replyUserName: _aList![index]
                                            .replyData![replyDataIndex]
                                            .userName
                                            .toString(),
                                        replyCommentThreeDotTap: () {
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return _showBottomSheetEditDel(
                                                    _aList![index]
                                                        .replyData![
                                                            replyDataIndex]
                                                        .replyCommentId
                                                        .toString(),
                                                    index,
                                                    _aList![index]
                                                        .replyData![
                                                            replyDataIndex]
                                                        .comment
                                                        .toString());
                                              });
                                        },
                                        visibilityCommentThreeDot:
                                            _aList![index]
                                                    .replyData![replyDataIndex]
                                                    .userId ==
                                                mineUserId,
                                        replyCommentData: _aList![index]
                                            .replyData![replyDataIndex]
                                            .comment
                                            .toString(),
                                        replyCommentTime: _commonHelper!
                                            .getTimeDifference(_aList![index]
                                                    .replyData![replyDataIndex]
                                                    .insertDate ??
                                                0));
                                  },
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
                            child: profileImage(index),
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
                                    Text(_aList![index].userName.toString(),
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
                                      child: Text(
                                          _aList![index].comment.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: SoloColor.black,
                                              fontSize: Constants.FONT_TOP)),
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
                                          onTap: () {
                                            replyId =
                                                _aList?[index].publicCommentId;

                                            FocusScope.of(context).requestFocus(
                                                _sendCommentFocusNode);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: Text(
                                              StringHelper.reply,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: SoloColor.spanishGray,
                                                  fontSize: Constants.FONT_LOW),
                                            ),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Text(
                                            "${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}",
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
                                  itemCount: _aList?[index].replyData?.length,
                                  itemBuilder: (context, replyDataIndex) {
                                    return CommentHelper.replyItem(context,
                                        listIndex: index,
                                        replyData: _aList![index]
                                            .replyData![replyDataIndex],
                                        replyIndex: replyDataIndex,
                                        viewAllTap: () {
                                          setState(() {
                                            _aList?[index].showReplies = true;
                                          });
                                        },
                                        viewAllReply: _aList?[index]
                                                    .replyData
                                                    ?.isNotEmpty ==
                                                true &&
                                            replyDataIndex == 0 &&
                                            _aList?[index].showReplies == false,
                                        viewAllReplyLength:
                                            '${_aList?[index].replyData?.length.toString()}',
                                        viewAllReplyComment:
                                            _aList![index].showReplies!,
                                        replyProfileImage: _aList![index]
                                            .replyData![replyDataIndex]
                                            .userProfilePic
                                            .toString(),
                                        replyUserName: _aList![index]
                                            .replyData![replyDataIndex]
                                            .userName
                                            .toString(),
                                        replyCommentThreeDotTap: () {
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return _showBottomSheetEditDel(
                                                    _aList![index]
                                                        .replyData![
                                                            replyDataIndex]
                                                        .replyCommentId
                                                        .toString(),
                                                    index,
                                                    _aList![index]
                                                        .replyData![
                                                            replyDataIndex]
                                                        .comment
                                                        .toString());
                                              });
                                        },
                                        visibilityCommentThreeDot:
                                            _aList![index]
                                                    .replyData![replyDataIndex]
                                                    .userId ==
                                                mineUserId,
                                        replyCommentData: _aList![index]
                                            .replyData![replyDataIndex]
                                            .comment
                                            .toString(),
                                        replyCommentTime: _commonHelper!
                                            .getTimeDifference(_aList![index]
                                                    .replyData![replyDataIndex]
                                                    .insertDate ??
                                                0));
                                  },
                                )
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

  Widget _commentListData(int pos) {
    return Container(
      width: _commonHelper?.screenWidth,
      color: SoloColor.white,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _hideKeyBoard();
            },
            child: Container(
              color: Colors.white,
              width: _commonHelper?.screenWidth,
              height: _commonHelper?.screenHeight * .825,
              padding: EdgeInsets.only(
                  bottom: DimensHelper.sidesMargin,
                  top: DimensHelper.halfSides),
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    color: SoloColor.platinum,
                  ),
                ),
                controller: _scrollController,
                itemCount: _aList!.length,
                padding: EdgeInsets.only(bottom: 56),
                itemBuilder: (context, index) {
                  // if (index == pos) {
                  //   return userDetails1(index);
                  // } else { }
                  return CommentHelper.userDetails(
                    context,
                    index,
                    userName: _aList![index].userName.toString(),
                    threeDotTap: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return _showBottomSheetEditDel(
                                _aList![index].publicCommentId.toString(),
                                index,
                                _aList![index].comment.toString());
                          });
                    },
                    content: _aList![index].comment.toString(),
                    replyTap: () {
                      replyId = _aList?[index].publicCommentId;

                      FocusScope.of(context)
                          .requestFocus(_sendCommentFocusNode);
                    },
                    commentTime:
                        "${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}",
                    replyCount: _aList![index].replyData!.length,
                    replyBuilder: (context, replyDataIndex) {
                      return CommentHelper.replyItem(context,
                          listIndex: index,
                          replyData: _aList![index].replyData![replyDataIndex],
                          replyIndex: replyDataIndex,
                          viewAllTap: () {
                            setState(() {
                              _aList?[index].showReplies = true;
                            });
                          },
                          viewAllReply:
                              _aList?[index].replyData?.isNotEmpty == true &&
                                  replyDataIndex == 0 &&
                                  _aList?[index].showReplies == false,
                          viewAllReplyLength:
                              '${_aList?[index].replyData?.length.toString()}',
                          viewAllReplyComment: _aList![index].showReplies!,
                          replyProfileImage: _aList![index]
                              .replyData![replyDataIndex]
                              .userProfilePic
                              .toString(),
                          replyUserName: _aList![index]
                              .replyData![replyDataIndex]
                              .userName
                              .toString(),
                          replyCommentThreeDotTap: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return _showBottomSheetEditDel(
                                      _aList![index]
                                          .replyData![replyDataIndex]
                                          .replyCommentId
                                          .toString(),
                                      index,
                                      _aList![index]
                                          .replyData![replyDataIndex]
                                          .comment
                                          .toString());
                                });
                          },
                          visibilityCommentThreeDot: _aList![index]
                                  .replyData![replyDataIndex]
                                  .userId ==
                              mineUserId,
                          replyCommentData: _aList![index]
                              .replyData![replyDataIndex]
                              .comment
                              .toString(),
                          replyCommentTime: _commonHelper!.getTimeDifference(
                              _aList![index]
                                      .replyData![replyDataIndex]
                                      .insertDate ??
                                  0));
                    },
                    idCheck: _aList?[index].userId == mineUserId ? true : false,
                    profilePic: _aList![index].userProfilePic.toString(),
                  );
                },
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                color: Colors.white,
                child: CommentHelper.sendCommentField(context, onSend: () {
                  isEditComment
                      ? _onEditCommentTap(replyId.toString())
                      : _onSendCommentTap(replyId.toString());
                },
                    controller: _sendCommentController,
                    autofocus: widget.showKeyBoard!,
                    focusNode: _sendCommentFocusNode,
                    id: replyId!),
              ),
            ],
          ),
          Visibility(
            visible: _aList!.isEmpty,
            child: Container(
              height: _commonHelper?.screenHeight * .8,
              child: Center(
                child: Text(StringHelper.noCommentOnPost,
                    style: TextStyle(
                        color: SoloColor.black,
                        fontSize: Constants.FONT_MEDIUM,
                        fontWeight: FontWeight.normal)),
              ),
            ),
          ),
          Align(
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          )
        ],
      ),
    );
  }

  // Widget sendCommentField() {
  //   return Row(
  //     children: [
  //       Expanded(
  //           child: Container(
  //         decoration: BoxDecoration(
  //           color: SoloColor.white,
  //           boxShadow: [
  //             BoxShadow(
  //               color: Color(0xffe8e8e8),
  //               blurRadius: 10.0,
  //               offset: Offset(0, -5),
  //             ),
  //           ],
  //         ),
  //         width: _commonHelper?.screenWidth * .78,
  //         padding: EdgeInsets.only(
  //             top: DimensHelper.halfSides, bottom: DimensHelper.halfSides),
  //         child: TextFormField(
  //           style: TextStyle(
  //             fontSize: Constants.FONT_MAXIMUM,
  //             color: SoloColor.spanishGray,
  //           ),
  //           autofocus: widget.showKeyBoard!,
  //           textInputAction: TextInputAction.newline,
  //           keyboardType: TextInputType.multiline,
  //           minLines: 1,
  //           maxLines: 4,
  //           focusNode: _sendCommentFocusNode,
  //           onTap: () {
  //             replyId = "";
  //
  //             _animateScrolling();
  //           },
  //           controller: _sendCommentController,
  //           cursorColor: SoloColor.blue,
  //           decoration: InputDecoration(
  //               hintText:
  //                   replyId!.isEmpty ? 'Write a comment' : 'Write a Reply',
  //               hintStyle: TextStyle(
  //                   color: SoloColor.spanishGray,
  //                   fontSize: Constants.FONT_MAXIMUM),
  //               suffixIcon: GestureDetector(
  //                   onTap: () {
  //                     isEditComment
  //                         ? _onEditCommentTap(replyId.toString())
  //                         : _onSendCommentTap(replyId.toString());
  //                   },
  //                   child: Padding(
  //                     padding: const EdgeInsets.only(
  //                         top: 10.0, bottom: 10.0, left: 10.0, right: 12.0),
  //                     child: Container(
  //                         height: _commonHelper?.screenHeight * 0.008,
  //                         child: SvgPicture.asset(
  //                           IconsHelper.commentSendBtn,
  //                         )),
  //                   )),
  //               fillColor: SoloColor.white,
  //               contentPadding: EdgeInsets.only(
  //                   top: DimensHelper.sidesMargin,
  //                   bottom: DimensHelper.sidesMargin,
  //                   left: DimensHelper.sidesMargin,
  //                   right: DimensHelper.sidesMargin),
  //               enabledBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(color: SoloColor.white, width: 1.0),
  //               ),
  //               border: OutlineInputBorder(
  //                   borderSide: BorderSide(color: SoloColor.white, width: 0.0)),
  //               focusedBorder: OutlineInputBorder(
  //                   borderSide:
  //                       BorderSide(color: SoloColor.white, width: 0.0))),
  //         ),
  //       )),
  //     ],
  //   );
  // }

//============================================================
// ** Helper Function **
//============================================================

  Future<bool> _willPopCallback() async {
    Navigator.pop(context, refreshData);

    return false;
  }

  void _getFeedCommentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();

          _feedCommentListBloc
              ?.getPublicFeedCommentList(
                  token.toString(), widget.publicFeedId.toString())
              .then((onValue) {
            _hideProgress();
          }).catchError((onError) {
            _hideProgress();
          });
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _deleteComment(var commentId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();

          _feedCommentListBloc
              ?.deleteComment(token.toString(), commentId)
              .then((onValue) {
            if (onValue) {
              refreshData = true;
              // _aList.removeAt(index);
              _aList?.clear();

              _hideProgress();
              _getFeedCommentList();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteSucMsg),
              ));
            } else {
              _hideProgress();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteUnSucMsg),
              ));
            }
          }).catchError((onError) {
            _hideProgress();
          });
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Future<bool>? dialogCommentDel(
      BuildContext context, String commentId, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DimensHelper.sidesMargin))),
        title: Text(StringHelper.deleteComment),
        titleTextStyle: TextStyle(
            fontSize: DimensHelper.sidesMargin, color: SoloColor.black),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(StringHelper.no,
                style: TextStyle(
                    color: SoloColor.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: DimensHelper.sidesMargin)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _deleteComment(commentId, index);
            },
            child: Text(StringHelper.yes,
                style: TextStyle(
                    color: SoloColor.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: DimensHelper.sidesMargin)),
          ),
        ],
      ),
    );
    //  ??
    // false;
    return null;
  }

  void _animateScrollingMessage(int pos) {
    var position = pos + 1;
    Timer(Duration(milliseconds: 500),
        () => _scrollController?.jumpTo(position.toDouble()));
  }

  void _animateScrolling() {
    Timer(
        Duration(milliseconds: 500),
        () => _scrollController
            ?.jumpTo(_scrollController!.position.maxScrollExtent));
  }

  void _hideKeyBoard() {
    replyId = "";

    FocusScope.of(context).unfocus();
  }

  void _onEditCommentTap(String publicCommentId) {
    FocusScope.of(context).unfocus();

    if (_sendCommentController.text.toString().isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.error, StringHelper.writeSomethingMsg, false));

      return;
    }

    var body = json.encode({
      "commentId": editFeedId,
      "comment": _sendCommentController.text.toString()
    });

    _sendCommentController.text = "";

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _apiHelper
            ?.updateCommentPublicFeed(body, authToken.toString())
            .then((onValue) {
          setState(() {
            isEditComment = false;
          });
          _aList?.clear();

          _getFeedCommentList();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onSendCommentTap(String publicCommentId) {
    widget.scrollMessage = false;

    if (_sendCommentController.text.toString().trim().isEmpty) {
      if (replyId!.isEmpty) {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _commonHelper!
                .successBottomSheet(StringHelper.invalidComment,
                    StringHelper.emptyComment, false));
      } else {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _commonHelper!
                .successBottomSheet(
                    StringHelper.invalidReply, StringHelper.emptyReply, false));
      }

      return;
    }

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body;

        if (publicCommentId.isEmpty) {
          body = json.encode({
            "publicFeedId": widget.publicFeedId,
            "comment": _sendCommentController.text.toString()
          });
        } else {
          body = json.encode({
            "publicFeedId": widget.publicFeedId,
            "comment": _sendCommentController.text.toString(),
            "publicCommentId": publicCommentId
          });
        }

        _sendCommentController.text = "";

        _feedCommentListBloc
            ?.submitFeedComment(authToken.toString(), body)
            .then((onValue) {
          refreshData = true;

          _hideKeyBoard();

          _aList?.clear();

          _getFeedCommentList();
        }).catchError((onError) {
          _hideKeyBoard();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _showProgress() {
    setState(() {
      _progressShow = true;
    });
  }

  void _hideProgress() {
    setState(() {
      _progressShow = false;
    });
  }
}
